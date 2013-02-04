Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailsrv.ikr.uni-stuttgart.de ([129.69.170.2]:39406 "EHLO
	mailsrv.ikr.uni-stuttgart.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754176Ab3BDUYU convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Feb 2013 15:24:20 -0500
Received: from netsrv1.ikr.uni-stuttgart.de (netsrv1-c [10.11.12.12])
	by mailsrv.ikr.uni-stuttgart.de (Postfix) with ESMTP id 1274960153
	for <linux-nfs@vger.kernel.org>; Mon,  4 Feb 2013 21:24:19 +0100 (CET)
Received: from vpn-2-cl173 (vpn-2-cl173 [10.41.21.173])
	by netsrv1.ikr.uni-stuttgart.de (Postfix) with ESMTP id 05F6F60152
	for <linux-nfs@vger.kernel.org>; Mon,  4 Feb 2013 21:24:18 +0100 (CET)
From: Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>
To: linux-nfs@vger.kernel.org
Subject: Re: Linux 3.7 + Sun solaris 10: Problems when reading dir from application
Date: Mon, 4 Feb 2013 21:24:08 +0100
References: <201302041112.03587.ulrich.gemkow@ikr.uni-stuttgart.de>
In-Reply-To: <201302041112.03587.ulrich.gemkow@ikr.uni-stuttgart.de>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201302042124.10739.ulrich.gemkow@ikr.uni-stuttgart.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

please allow a followup of my own on this:

On Monday 04 February 2013 11:12:03 Ulrich Gemkow wrote:
> Hello,
> 
> we upgraded our fileserver from Linux 3.2 to linux 3.7.6 and now have
> problems when accessing our nfs-mounted user homes from some sun-
> applications (i.e. Adobe Framemaker):
> 
> In the applications file open box, no files are displayed. When entering
> the filename by path, the file can be opened. So it seems some kind of
> dir enumeration which is used by the sun applications is broken.
> 
> Other programs on the sun like ls work as before and show all files.
> 
> We are using NFSv3 (and cannot switch to v4). Our sun is a very old
> machine running Sun Solaris 10.

When mounting with vers=2 on the sun (using NFSv2) the files
"reappear", so this is a clear regression in NFSv3 between
Linux 3.2 and Linux 3.7.

Maybe this can be fixed. I will be happy to give more info
if someone is interested.

Best regards

Ulrich

> 
> Is there any help?
> 
> Thanks and best regards
> 
> Ulrich
> 


-- 
|-----------------------------------------------------------------------
| Ulrich Gemkow
|-----
| Universität Stuttgart
| Institut für Kommunikationsnetze und Rechnersysteme (IKR)
|-----
| University of Stuttgart
| Institute of Communication Networks and Computer Engineering (IKR)
|-----
| Pfaffenwaldring 47, D 70569 Stuttgart, Germany
| mailto:gemkow@ikr.uni-stuttgart.de   http://www.ikr.uni-stuttgart.de
|-----------------------------------------------------------------------
