Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44834 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753593AbcLFTZt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Dec 2016 14:25:49 -0500
Subject: Re: [RFC PATCH 00/15] Enhance /etc/nfs.conf usage and remove
 nfs-config.service
To: NeilBrown <neilb@suse.com>, "J. Bruce Fields" <bfields@redhat.com>
References: <148065078775.28046.5506130555300891075.stgit@noble>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <ab0ce4e9-fd03-7cee-5ce2-5317c522db8f@RedHat.com>
Date: Tue, 6 Dec 2016 14:25:46 -0500
MIME-Version: 1.0
In-Reply-To: <148065078775.28046.5506130555300891075.stgit@noble>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/01/2016 10:58 PM, NeilBrown wrote:
> This is an RFC series.  A little voice at the back of my head keeps
> telling me that I'm over-engineering, but there isn't really that much
> new code, and I think the result has a lot to recommend it.
> 
> But please tell me if I'm wrong.
> 
> - Various daemons (not all) are enhance to accept configuration
>   information from /etc/nfs.conf
> - the conffile reader is enhanced to support include files, and
>   particularly to be able to include /etc/sysconf/X or /etc/defaults/X
>   files usefully
> - nfs-config.service is removed, because it isn't really needed with
>   the above.
> - documentation for all the above is provided, including a new
>   nfs.systemd man page which gives the bigger picture.
> 
Here is the nfs.conf I will be using to do my testing... 
I'm just wondering if this is something we should put in the git tree? 

#
# This is a general conifguration for the 
# NFS daemons and tools
#
#[nfsdcltrack]
# storagedir=/var/lib/nfs/nfsdcltrack
#
#[nfsd]
# threads=8
# grace-time=90
# lease-time=90
# udp=y
# tcp=y
# vers2=n
# vers3=y
# vers4=y
# vers4.0=y
# vers4.1=y
# vers4.2=y
# rdma=n
# 
#[mountd]
# manage_gids=n
# descriptors=0
# port=42258
# threads=1
# reverse-lookup=n
# state-directory-path=/var/lib/nfs
# ha-callout=NULL
#
#[statd]
# port=0
# outgoing-port=0
# name=NULL
# state-directory-path=/var/lib/nfs/statd
# ha-callout=NULL
#
#[lockd]
# port=0
# udp-port=0
#
#[sm-notify]
# retry-time=900
# outgoing-port=NULL
# outgoing-addr=NULL
#



