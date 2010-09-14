Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod6og111.obsmtp.com ([64.18.1.27]:39753 "HELO
	exprod6og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752816Ab0INMLE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Sep 2010 08:11:04 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: NFS : filehandle to filename mappings.
Date: Tue, 14 Sep 2010 08:10:51 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90D35B46C@nsmail.netscout.com>
From: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
To: <linux-nfs@vger.kernel.org>
Cc: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

Sorry, the question might sound repeated; but I am looking for some
other details here. 
I looked at the NFS protocol packets. I could see that in case of
file/directory operations(e.g. vi a file) some of the NFS packets (e.g.
GETATTR procedure) show just the filehandle. But later when the LOOKUP
is executed the corresponding NFS packet shows the filename (I observed
in case of regular file).

Could someone please provide some information on how it gets the file
name in some of the packets (i.e. related to LOOKUP, WRITE etc.)? Does
it refer the lookup table at NFS server side and fills-in the name in
response?

Appreciate any help.

P.S. Request you to copy me in the reply, I am not subscribed to the
list.

--
Thanks,
Nilesh


