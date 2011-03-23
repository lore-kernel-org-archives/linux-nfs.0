Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24060 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752653Ab1CWSeE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 14:34:04 -0400
Subject: Re: [PATCH 3/3] NFS: Detect loops in a readdir due to bad cookies
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Bryan Schumaker <bjschuma@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <20110323182524.GB25284@fieldses.org>
References: <4D8A3060.807@netapp.com>  <20110323182524.GB25284@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 23 Mar 2011 14:34:03 -0400
Message-ID: <1300905243.11677.53.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-03-23 at 14:25 -0400, J. Bruce Fields wrote:
> On Wed, Mar 23, 2011 at 01:39:44PM -0400, Bryan Schumaker wrote:
> > Some filesystems (such as ext4) can return the same cookie value for multiple
> 
> Do the ext4 people know about this?  (And what's the easiest way to
> reproduce it?)

They are aware of it. I don't know if they are aware how easy it is to
reproduce.

Bryan saw several 10s of instances of duplicate cookies when he was
doing performance testing of readdir on a directory with 10^6 entries.
Most of the time it didn't cause looping on the client since the looping
behaviour depends on the distribution of those cookies in the client's
readdir cache. However on occasion he did see looping in the client, and
at least once he saw looping on the server too (in which a duplicate
cookie caused the server to return files that it had already sent to the
client).

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

