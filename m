Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:58293 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758Ab2FLQeM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Jun 2012 12:34:12 -0400
From: "Welch, Brent" <welch@panasas.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Harrosh, Boaz" <bharrosh@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        Andy Adamson <androsadamson@gmail.com>, NFSv4 <nfsv4@ietf.org>
Subject: RE: RFC 5661 LAYOUTRETURN clarification.
Date: Tue, 12 Jun 2012 16:34:06 +0000
Message-ID: <DA636AC7BF798243A4007D3AA0B3D3A75AB40E9D@seabiscuit.int.panasas.com>
References: <CAHVgHyUpM0rQWqO5-id+FohPKm1Lk=kkekf7HqzpfKcfvxx23A@mail.gmail.com>
	<4FD63BAF.8040107@panasas.com> <1339441159.19775.25.camel@lade.trondhjem.org>
In-Reply-To: <1339441159.19775.25.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is why the objects layout communicates errors upon layout return.

When you suffer write timeouts (or any errors) with a DS, then the client promptly returns the layout with an indication of what went wrong.  This should be the intent of whatever words are in the RFC.

--
Brent


-----Original Message-----
From: nfsv4-bounces@ietf.org [mailto:nfsv4-bounces@ietf.org] On Behalf Of Myklebust, Trond
Sent: Monday, June 11, 2012 11:59 AM
To: Harrosh, Boaz
Cc: NFS list; Adamson, Andy; Andy Adamson; NFSv4
Subject: Re: [nfsv4] RFC 5661 LAYOUTRETURN clarification.

On Mon, 2012-06-11 at 21:40 +0300, Boaz Harrosh wrote:

> And again, please explain why do you want it. What is wrong with the
> case we all agree with? ie: "Client can not call LAYOUTRETURN until
> all in-flight RPCs return, with or without an error"

Who "agreed" to this? This would mean that if the DS goes down, we can't
ever send LAYOUTRETURN which is patently wrong.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4
