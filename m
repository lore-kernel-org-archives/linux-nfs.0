Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53939 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753227Ab1G0Prh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jul 2011 11:47:37 -0400
Date: Wed, 27 Jul 2011 11:47:36 -0400
To: Robert Marcano <robert@marcanoonline.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 / POSIX ACL mapping bug?
Message-ID: <20110727154736.GB974@fieldses.org>
References: <4E2ED2A0.4030401@marcanoonline.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E2ED2A0.4030401@marcanoonline.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jul 26, 2011 at 10:13:44AM -0430, Robert Marcano wrote:
> Hi, This question is probably too simple for this nfs developer
> list, but I am intrigued to know if this is a bug or not, I do not
> find any other reference to anyone with this problem
> 
> Ineed some help clarifying this issue in order to know if this is a
> bug or limits of the NFSv4 / POSIX ACL mapping before reporting it
> 
> Creating a directory on the server with the following POSIX ACLs,
> rwx for the group "sharedgroup" and same defaults:
> 
> ############################################################
> # file: directory
> # owner: root
> # group: root
> user::rwx
> group::r-x
> group:sharedgroup:rwx
> mask::rwx
> other::---
> default:user::rwx
> default:group::r-x
> default:group:sharedgroup:rwx
> default:mask::rwx
> default:other::---
> ############################################################
> 
> Creating files with the same user with umask 022 on the server an on
> the NFS client, the files do not get the same POSIX ACL mask:
> 
> ############################################################
> # file: client
> # owner: test
> # group: testgroup
> user::rw-
> group::r-x                   #effective:r--
> group:sharedgroup:rwx        #effective:r--
> mask::r--
> other::r--
> 
> # file: server
> # owner: test
> # group: testgroup
> user::rw-
> group::r-x                   #effective:r--
> group:sharedgroup:rwx        #effective:rw-
> mask::rw-
> other::r--
> ############################################################
> 
> Is this normal or a bug?, My interpretation is that even that the
> mapping of the ACLs is not 100% perfect this simple example should
> not be a problem. Is it impossible using NFS to create a shared
> directory for a group of users?

Without looking at your example carefully, it sounds like the same
problem as discussed here:

	http://marc.info/?t=123739823200003&r=1&w=2

--b.
