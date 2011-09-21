From: DENIEL Philippe <philippe.deniel@cea.fr>
Subject: Re: [nfsv4] Reminder on October 2011 BAT
Date: Wed, 21 Sep 2011 15:03:54 +0200
Message-ID: <4E79E0BA.5040906@cea.fr>
References: <721C2207-5FBE-4886-8B2C-955961564755@netapp.com> <869E9B5A-E664-43C6-B8BC-BBC0A2158CB8@netapp.com> <4E785048.7080607@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Cc: Thomas Haynes <thomas@netapp.com>, nfsv4@ietf.org,
	"Matt W. Benjamin" <matt@linuxbox.com>,
	"Adam C. Emerson" <aemerson@linuxbox.com>,
	Marc Eshel <eshel@almaden.ibm.com>,
	Ganesha NFS List <nfs-ganesha-devel@lists.sourceforge.net>,
	NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sainfoin-out.extra.cea.fr ([132.167.192.144]:57297 "EHLO
	sainfoin-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160Ab1IUOVD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2011 10:21:03 -0400
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by sainfoin.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.2) with ESMTP id p8LD3tux009647
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Wed, 21 Sep 2011 15:03:55 +0200
Received: from muguet2.intra.cea.fr (muguet2.intra.cea.fr [132.166.192.7])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id p8LD3tOx019887
	for <linux-nfs@vger.kernel.org>; Wed, 21 Sep 2011 15:03:55 +0200
	(envelope-from philippe.deniel@cea.fr)
Received: from zia.esteban.ctsi (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet2.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.1) with SMTP id p8LD3sLH009577
	for <linux-nfs@vger.kernel.org>; Wed, 21 Sep 2011 15:03:55 +0200
In-Reply-To: <4E785048.7080607@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Boaz Harrosh a =C3=A9crit :
> If so we will want one set aside for:
> 	"Design of NFS-Ganesha pNFS Server infrastructure"
>
> We will be a bunch of Ganesha guys on campus but I think it will be v=
ery interesting
> for anybody who's interested in pNFS Server design and implementation=
=2E
>  =20
This is a pretty good idea. I suggest we extend the topic by talking=20
about FSAL_CB infrastructure too : speaking of pNFS will lead us to=20
speak of LAYOUT_RETURN which requires callbacks from the FS.

    Regards

       Philippe
