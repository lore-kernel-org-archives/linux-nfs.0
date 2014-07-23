Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail1.g1.pair.com ([66.39.3.162]:61945 "EHLO mail1.g1.pair.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932114AbaGWRAE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jul 2014 13:00:04 -0400
Date: Wed, 23 Jul 2014 18:54:19 +0200
From: Emmanuel Florac <eflorac@intellique.com>
To: sheng qiu <herbert1984106@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: how to setup pNFS
Message-ID: <20140723185419.7a947ada@harpe.intellique.com>
In-Reply-To: <CAB7xdikp2ab=oqQKz+DVLh0D5G9aB7EMd4XWttLh3qFE8Fp9qA@mail.gmail.com>
References: <CAB7xdikp2ab=oqQKz+DVLh0D5G9aB7EMd4XWttLh3qFE8Fp9qA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le Wed, 23 Jul 2014 09:13:51 -0700
sheng qiu <herbert1984106@gmail.com> écrivait:

> i am trying to set up pNFS server and client. is there any document
> can help that?
> i tried to follow the
> http://wiki.linux-nfs.org/wiki/index.php/PNFS_Setup_Instructions, but
> i did not have /proc/fs/nfsd/pdfs_dlm_device entry.

Did you compile the pNFS kernel? Then did you reboot using that kernel?
This is step 0 in the instructions. 

-- 
------------------------------------------------------------------------
Emmanuel Florac     |   Direction technique
                    |   Intellique
                    |	<eflorac@intellique.com>
                    |   +33 1 78 94 84 02
------------------------------------------------------------------------
