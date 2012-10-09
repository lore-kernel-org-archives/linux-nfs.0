Return-Path: linux-nfs-owner@vger.kernel.org
Received: from charon.rus.uni-stuttgart.de ([129.69.1.54]:41397 "EHLO
	charon.rus.uni-stuttgart.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755686Ab2JIOHV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Oct 2012 10:07:21 -0400
Received: from localhost (localhost [127.0.0.1])
	by charon.rus.uni-stuttgart.de (Postfix) with ESMTP id 23EBA5FDA8
	for <linux-nfs@vger.kernel.org>; Tue,  9 Oct 2012 15:59:21 +0200 (CEST)
Received: from charon.rus.uni-stuttgart.de ([127.0.0.1])
	by localhost (charon.rus.uni-stuttgart.de [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id NHyV8LZjqO45 for <linux-nfs@vger.kernel.org>;
	Tue,  9 Oct 2012 15:59:19 +0200 (CEST)
Received: from tindra.iws.uni-stuttgart.de (tindra.iws.uni-stuttgart.de [129.69.98.190])
	by charon.rus.uni-stuttgart.de (Postfix) with ESMTP
	for <linux-nfs@vger.kernel.org>; Tue,  9 Oct 2012 15:59:19 +0200 (CEST)
Date: Tue, 9 Oct 2012 15:59:19 +0200
From: David Werner <david.werner@iws.uni-stuttgart.de>
To: linux-nfs@vger.kernel.org
Subject: Problem with NFSv4 (server: NetApp-Filer, client openSUSE-11.4,
 12.1 and 12.2)
Message-ID: <20121009135919.GA16012@tindra.iws.uni-stuttgart.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, 

We have a serious problem to use NFS v4 with recent openSUSE versions.
Provided that I have write permission to the directory I touch, I can do
the following for getting a stale file handle:

> touch .. 
> ls
ls: cannot open directory .: Stale NFS file handle

This makes the filesystem quite unusable, as anything which touches a
directory above (like writing a file) can stop an application.
If I leave the directory and cd into it again, it content is listable.
>From our computing center that the server runs I got the information
that it is NetApp ONTAP 7.3.6P4. 
I observed the problem here with openSUSE-11.4 (kernel: 2.6.37.6-0.20-desktop),
openSUSE-12.1 (kernel: 3.4.4-1-desktop), openSUSE-12.2 (kernel: 3.4.6-2.10-desktop)
and  all x86_64 architecture but _not_ with openSUSE-11.3 (kernel: 2.6.34.10-0.6-desktop).
We use NFSv4 without encryption and userdata from NIS.
I'm looking for suggestions to resolve this problem.


Best regards, David

-- 
David Werner
Universitaet Stuttgart
Institut für Wasser- und Umweltsystemmodellierung
Lehrstuhl fuer Hydromechanik &  Hydrosystemmodellierung
Pfaffenwaldring 61 ** 70569 Stuttgart
Tel.: ++49-711-685 67010 ** Fax: ++49-711-685 60430
david.werner@iws.uni-stuttgart.de
http://www.hydrosys.uni-stuttgart.de/
