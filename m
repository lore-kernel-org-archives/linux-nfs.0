Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ebox.rath.org ([173.255.235.238]:53021 "EHLO ebox.rath.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750947Ab1JVUsM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Oct 2011 16:48:12 -0400
References: <87ipnlcbg8.fsf@inspiron.ap.columbia.edu> <20111019171551.GA32028@fieldses.org> <87d3dsdcf4.fsf@inspiron.ap.columbia.edu> <20111020120207.GL5444@fieldses.org> <877h3za89w.fsf@inspiron.ap.columbia.edu> <20111020195731.GC9987@fieldses.org> <871uu79z7m.fsf@inspiron.ap.columbia.edu> <1319155647.2768.4.camel@lade.trondhjem.org> <87vcrisb5y.fsf@inspiron.ap.columbia.edu> <1319212854.4537.9.camel@lade.trondhjem.org> <4EA1994D.6060700@rath.org> <1319217023.4537.28.camel@lade.trondhjem.org> <4EA1AF6D.60603@rath.org> <4EA30FC7.7080600@panasas.com>
In-Reply-To: <4EA30FC7.7080600@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: Does NFS4 need st_gen?
From: Nikolaus Rath <Nikolaus@rath.org>
Date: Sat, 22 Oct 2011 16:10:46 -0400
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Message-ID: <76b3967b-5604-43c9-abd1-06c1b3a7e22c@email.android.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Boaz Harrosh <bharrosh@panasas.com> wrote:

>On 10/21/2011 10:44 AM, Nikolaus Rath wrote:
>> Yes, with 64bit inodes everything would be fine. But fuse uses 'long'
>> for inodes, so on 32bit systems you only have 32bit inodes even if
>ino_t
>> is 64bit.
>
>With out knowing any of the details, what kind of brain dead thing is
>putting "long" in an API. What do you do with 32bit user-mode on 64bit
>Kernel.

It's called a bug, they are known to appear occasionally in computer software.

>
>32 bits for inode numbers is a broken system for 15 years already.
>Fix the broken FUSE that falsely calls itself File-System and
>stop bitching about NFS. It's FUSE you should be hacking and fixing.

I merely answered the question of why I was interested in generation numbers in NFS4.


Best,
Nikolaus 
-- 
Sent from my Android phone with K-9 Mail. Please excuse my brevity.
