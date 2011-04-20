Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sainfoin-out.extra.cea.fr ([132.167.192.144]:43870 "EHLO
	sainfoin-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127Ab1DTHyM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 03:54:12 -0400
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by sainfoin.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.2) with ESMTP id p3K7sAxg007489
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Wed, 20 Apr 2011 09:54:10 +0200
Received: from muguet1.intra.cea.fr (muguet1.intra.cea.fr [132.166.192.6])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id p3K7sAEI032545
	for <linux-nfs@vger.kernel.org>; Wed, 20 Apr 2011 09:54:10 +0200
	(envelope-from philippe.deniel@cea.fr)
Received: from zia.bruyeres.cea.fr (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet1.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.1) with SMTP id p3K7s9kN013904
	for <linux-nfs@vger.kernel.org>; Wed, 20 Apr 2011 09:54:09 +0200
Message-ID: <4DAE9121.9090500@cea.fr>
Date: Wed, 20 Apr 2011 09:54:09 +0200
From: DENIEL Philippe <philippe.deniel@cea.fr>
To: =?ISO-8859-15?Q?Peter_=C5strand?= <astrand@cendio.se>
CC: linux-nfs@vger.kernel.org
Subject: Re: Save the unfs3 project
References: <alpine.LFD.2.02.1104191614010.23639@stella.lkpg.cendio.se>
In-Reply-To: <alpine.LFD.2.02.1104191614010.23639@stella.lkpg.cendio.se>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Peter,
> Another option, I guess, would be to discontinue the unfs3 project and 
> recommend users to migrate to nfs-ganesha, or something like that. Any 
> users of ganesha on this list? I don't know much about it.
I am the project lead for nfs-ganesha. I would be happy to provide you 
with all  information that would help you.

> Unfortunately it seems like it does not support Windows, which we need.
There is currently no port of nfs-ganesha to windows. I am working on a 
linux environment and so does the other folks contributing to the 
project. Anyway, I do not think that a port to windows would be 
something impossible. Matt Benjamin (from the LinuxBox company) 
succeeded once in compiling nfs-ganesha on cygwin on a windows platform. 
It seems to me there are tools at Microsoft's to ease port of unix 
applications to Windows, but I am no expert of this. Anyway, the 
linux-nfs is probably not the right place for discussing of this, I 
suggest that we continue talking of this on the nfs-ganesha's 
development list whose address is nfs-ganesha-devel@lists.sourceforge.net .

    Regards

       Philippe

