From: =?ISO-8859-1?Q?Andr=E9_Roth?= <andre.roth-omB+W0Dpw2o@public.gmane.org>
Subject: NFS4ERR_RESOURCE returns Remote IO Error
Date: Fri, 11 Sep 2009 09:46:43 +0200
Message-ID: <4AAA0063.4070406@bfh.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mr1.bfh.ch ([147.87.250.50]:34851 "EHLO mr1.bfh.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754065AbZIKHxg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2009 03:53:36 -0400
Received: from bfhsrv03.bfh.ch (bfhsrv03.bfh.ch [147.87.244.53])
	by mr1.bfh.ch (8.13.8/8.13.8) with ESMTP id n8B7ki60010251
	for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2009 09:46:44 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hello list,

We have a problem with the NFS client on Linux on a NetApp filer. Every
now and then we are getting huge amounts of "Remote IO Errors" on the
mounted home directories. This is new, we had no problems with the same
setup some months ago.

The reason for the Remote IO Errors is that the server is returning an
NFS4ERR_RESOURCE error, even just for
a simple "touch foo". The tcpdump of such a touch command I have listed
below.

I suspect that maybe the deduplication or backup operation make the
filer "busy" so it cannot respond to all compound operations.

I've seen that linux NFS just passes this error to the user as
EREMOTEIO. OpenSolaris seems to delay and retry. According to the RFC
I'm not sure what would be the right thing to do. But I think this is
meant to be a temporary error, and an NFS client should, in the example
below, take the first two operations as completed, and retry the
remaining 5 ones, or maybe retry the whole compound message.

What is your insight on this error ?
Is there something I can try, like returning EAGAIN and see if the erro=
r
gets handled correctly ?
The problem ocurred one or twice a week, without any regularity..

Thanks for your help

 Andr=E9


"touch foo" request from the client:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
NFS      V4 COMPOUND Call PUTFH;SAVEFH;OPEN;GETFH;GETATTR;
RESTOREFH;GETATTR
Remote Procedure Call, Type:Call XID:0x00c46a7a
Network File System
    [Program Version: 4]
    [V4 Procedure: COMPOUND (1)]
    Tag: <EMPTY>
        length: 0
        contents: <EMPTY>
    minorversion: 0
    Operations (count: 7)
        Opcode: PUTFH (22)
        Opcode: SAVEFH (32)
        Opcode: OPEN (18)
        Opcode: GETFH (10)
        Opcode: GETATTR (9)
        Opcode: RESTOREFH (31)
        Opcode: GETATTR (9)
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D


Error Response from the server:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
NFS      V4 COMPOUND Reply PUTFH;SAVEFH;OPEN
Remote Procedure Call, Type:Reply XID:0x00c46a7a
Network File System
    [Program Version: 4]
    [V4 Procedure: COMPOUND (1)]
    Status: NFS4ERR_RESOURCE (10018)
    Tag: <EMPTY>
        length: 0
        contents: <EMPTY>
    Operations (count: 3)
        Opcode: PUTFH (22)
            Status: NFS4_OK (0)
        Opcode: SAVEFH (32)
            Status: NFS4_OK (0)
        Opcode: OPEN (18)
            Status: NFS4ERR_RESOURCE (10018)
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D








