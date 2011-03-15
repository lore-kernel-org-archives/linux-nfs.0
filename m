Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from oxalide-out.extra.cea.fr ([132.168.224.8]:57908 "EHLO
	oxalide-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755129Ab1COPat (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Mar 2011 11:30:49 -0400
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by oxalide.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.2) with ESMTP id p2FF7idw010253
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Tue, 15 Mar 2011 16:07:44 +0100
Received: from muguet2.intra.cea.fr (muguet2.intra.cea.fr [132.166.192.7])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id p2FF7i9k007052
	for <linux-nfs@vger.kernel.org>; Tue, 15 Mar 2011 16:07:45 +0100
	(envelope-from philippe.deniel@cea.fr)
Received: from zia.bruyeres.cea.fr (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet2.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.1) with SMTP id p2FF7i2q004404
	for <linux-nfs@vger.kernel.org>; Tue, 15 Mar 2011 16:07:44 +0100
Message-ID: <4D7F80C0.2020405@cea.fr>
Date: Tue, 15 Mar 2011 16:07:44 +0100
From: DENIEL Philippe <philippe.deniel@cea.fr>
To: linux-nfs@vger.kernel.org
Subject: NFSv4 and NFSv4.1 client recovery
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

as you may know, I am working on a NFS server in user space called 
nfs-ganesha. One of the feature of nfs-ganesha is its capability of 
being used as a NFSv4 proxy. This is implemented as a backend in 
nfs-ganesha : all the filesystem that nfs-ganesha can export have a 
dedicated module with a well known API (this module is called FSAL for 
File System Abstraction layer). The proxy feature is made by make a FSAL 
library that is a NFSv4 basic client (each of the FSAL functions calls 
wrap one or more NFSv4 request). The trouble is the case when the remote 
server (the one accessed by the proxy operating as a client via FSAL 
calls) crashes : the client inside the FSAL needs to recover to the 
remote server as it comes back to work. My question is : what is the 
simpliest way for my user space client to recover ? I must precise it 
make no delegation and use only a forechannel to the remote server. 
There is no backchannel.

    Regards

       Philippe
