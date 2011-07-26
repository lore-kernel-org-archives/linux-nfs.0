Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14402 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752681Ab1GZSdp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jul 2011 14:33:45 -0400
Subject: Re: NFSv4 / POSIX ACL mapping bug?
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <4E2ED2A0.4030401@marcanoonline.com>
Date: Tue, 26 Jul 2011 14:33:28 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <D7BF98E9-394A-4364-8124-1E39BEBE85DC@netapp.com>
References: <4E2ED2A0.4030401@marcanoonline.com>
To: Robert Marcano <robert@marcanoonline.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi

Which client, which server (distro and uname -a output) did you use? Also, what commands (setfacl,getfacl? nfs4_setfacl, nfs4_getfacl ? plus version) and parameters did you use?

-->Andy
On Jul 26, 2011, at 10:43 AM, Robert Marcano wrote:

> Hi, This question is probably too simple for this nfs developer list, but I am intrigued to know if this is a bug or not, I do not find any other reference to anyone with this problem
> 
> Ineed some help clarifying this issue in order to know if this is a bug or limits of the NFSv4 / POSIX ACL mapping before reporting it
> 
> Creating a directory on the server with the following POSIX ACLs, rwx for the group "sharedgroup" and same defaults:
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
> Creating files with the same user with umask 022 on the server an on the NFS client, the files do not get the same POSIX ACL mask:
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
> Is this normal or a bug?, My interpretation is that even that the mapping of the ACLs is not 100% perfect this simple example should not be a problem. Is it impossible using NFS to create a shared directory for a group of users?
> 
> Thanks in advance
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

