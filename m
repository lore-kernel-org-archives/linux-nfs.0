From: Knut Petersen <Knut_Petersen@t-online.de>
Subject: Re: [BUG] nfs version 2 broken
Date: Wed, 01 Feb 2006 07:34:39 +0100
Message-ID: <43E0567F.20004@t-online.de>
References: <43E05031.2000107@t-online.de> <1138774519.7861.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-kernel@vger.kernel.org, neilb@cse.unsw.edu.au,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030542AbWBAGeR@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1138774519.7861.4.camel@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trond Myklebust schrieb:

>What kind of server is this that you are using? The above message
>basically means that it is handing out inodes with a link count of 0.
>
>Cheers,
>  Trond
>  
>

Server:
=====

AOpen i915GMm-HFS with Pentium M, linux kernel 2.6.15-git7
running a system that startet as SuSE 9.2. Nfs-utils are still
the original 1.0.6, grep -i nfs linuxbuild/.config gives

    CONFIG_NFS_FS=y
    CONFIG_NFS_V3=y
    # CONFIG_NFS_V3_ACL is not set
    # CONFIG_NFS_V4 is not set
    # CONFIG_NFS_DIRECTIO is not set
    CONFIG_NFSD=y
    CONFIG_NFSD_V3=y
    # CONFIG_NFSD_V3_ACL is not set
    # CONFIG_NFSD_V4 is not set
    CONFIG_NFSD_TCP=y
    CONFIG_NFS_COMMON=y

Client
====

kernel build from the same source,

    CONFIG_NFS_FS=y
    CONFIG_NFS_V3=y
    # CONFIG_NFS_V3_ACL is not set
    # CONFIG_NFS_V4 is not set
    # CONFIG_NFS_DIRECTIO is not set
    CONFIG_NFSD=y
    CONFIG_NFSD_V3=y
    # CONFIG_NFSD_V3_ACL is not set
    # CONFIG_NFSD_V4 is not set
    CONFIG_NFSD_TCP=y
    CONFIG_ROOT_NFS=y
    CONFIG_NFS_COMMON=y

cu,
 Knut
