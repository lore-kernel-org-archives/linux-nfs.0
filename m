Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:39384 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211Ab1JVSs2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Oct 2011 14:48:28 -0400
Message-ID: <4EA30FC7.7080600@panasas.com>
Date: Sat, 22 Oct 2011 11:47:35 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Nikolaus Rath <Nikolaus@rath.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: Re: Does NFS4 need st_gen?
References: <87ipnlcbg8.fsf@inspiron.ap.columbia.edu>		 <20111019171551.GA32028@fieldses.org>		 <87d3dsdcf4.fsf@inspiron.ap.columbia.edu>		 <20111020120207.GL5444@fieldses.org>		 <877h3za89w.fsf@inspiron.ap.columbia.edu>		 <20111020195731.GC9987@fieldses.org>		 <871uu79z7m.fsf@inspiron.ap.columbia.edu>		 <1319155647.2768.4.camel@lade.trondhjem.org>		 <87vcrisb5y.fsf@inspiron.ap.columbia.edu>	 <1319212854.4537.9.camel@lade.trondhjem.org> <4EA1994D.6060700@rath.org> <1319217023.4537.28.camel@lade.trondhjem.org> <4EA1AF6D.60603@rath.org>
In-Reply-To: <4EA1AF6D.60603@rath.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/21/2011 10:44 AM, Nikolaus Rath wrote:
> Yes, with 64bit inodes everything would be fine. But fuse uses 'long'
> for inodes, so on 32bit systems you only have 32bit inodes even if ino_t
> is 64bit.

With out knowing any of the details, what kind of brain dead thing is
putting "long" in an API. What do you do with 32bit user-mode on 64bit
Kernel.

32 bits for inode numbers is a broken system for 15 years already.
Fix the broken FUSE that falsely calls itself File-System and
stop bitching about NFS. It's FUSE you should be hacking and fixing.

Realy
Boaz

