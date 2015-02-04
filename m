Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp5-g21.free.fr ([212.27.42.5]:56064 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965247AbbBDQDv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2015 11:03:51 -0500
Date: Wed, 4 Feb 2015 17:03:56 +0100
From: Emmanuel Florac <eflorac@intellique.com>
To: dE <de.techno@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Cant get to export this particular directory.
Message-ID: <20150204170356.14e1e381@harpe.intellique.com>
In-Reply-To: <54D237A5.1050302@gmail.com>
References: <54D237A5.1050302@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le Wed, 04 Feb 2015 20:45:49 +0530
dE <de.techno@gmail.com> écrivait:

> I'm trying to export a particular directory with these parameters --
> 
> /home/test/huge/temp_small/subdir 
> fc00::5000/124(ro,anonuid=1000,anongid=1000,subtree_check)
> 
> For all subdirectories in temp_small, the client fails to mount
> saying permission denied.

Is temp_small a mountpoint? What are the mount options?

-- 
------------------------------------------------------------------------
Emmanuel Florac     |   Direction technique
                    |   Intellique
                    |	<eflorac@intellique.com>
                    |   +33 1 78 94 84 02
------------------------------------------------------------------------
