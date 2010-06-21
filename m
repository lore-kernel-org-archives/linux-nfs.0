Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cirse-out.extra.cea.fr ([132.166.172.106]:53703 "EHLO
	cirse-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932288Ab0FULm7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jun 2010 07:42:59 -0400
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by cirse.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.0) with ESMTP id o5LBgwGM022152
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 21 Jun 2010 13:42:58 +0200
Received: from muguet1.intra.cea.fr (muguet1.intra.cea.fr [132.166.192.6])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id o5LBgwIH010860
	for <linux-nfs@vger.kernel.org>; Mon, 21 Jun 2010 13:42:58 +0200
	(envelope-from Philippe.DENIEL@CEA.FR)
Received: from zia.bruyeres.cea.fr (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet1.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.1) with SMTP id o5LBgwcT003586
	for <linux-nfs@vger.kernel.org>; Mon, 21 Jun 2010 13:42:58 +0200
Message-ID: <4C1F5041.4050408@cea.fr>
Date: Mon, 21 Jun 2010 13:42:57 +0200
From: DENIEL Philippe <philippe.deniel@cea.fr>
To: linux-nfs@vger.kernel.org
Subject: RPCL source file for NFSv3 XATTR ?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I just saw James's patches about XATTR support in NFSv3. I am really
interested in this : in nfs-ganesha, my userspace NFS server, I already
implemented XATTR as "fake directories" (in fact, if your have an fs
object, for example a file name "myfile", then you can cd in a fake
directory .xattr.d.myfile where each "fake files" is an extended
attribute. Set/Gey on xattr are made via calls to WRITE/READ on the fake
files (and you can create/delete them as well). The NFSv3 XATTR interest
because is seem to have connexions with the gexattr/setxattr/removexattr
API, which means connexion with 'attr' command line and so make xattr
through NFS much more transparent than what I did with my .xattr.d.*
fake directories.
I could quickly had the NFSv3 Xattr (with compatibility with James's
patches), I just have to implement the right additional NFSv3 functions.
In order to do this, I just need RPCL descriptions of the xattr
dedicated NFSv3 functions. Where could I find this ?

    Thanks in advance for your help

       Philippe

