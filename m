Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail1.g1.pair.com ([66.39.3.162]:34886 "EHLO mail1.g1.pair.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753386AbaIYQ1o convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Sep 2014 12:27:44 -0400
Date: Thu, 25 Sep 2014 18:30:34 +0200
From: Emmanuel Florac <eflorac@intellique.com>
To: MJ Jenkins <mack.jenkins@eas.gatech.edu>
Cc: <linux-nfs@vger.kernel.org>
Subject: Re: NFS Share To OS X
Message-ID: <20140925183034.432731eb@harpe.intellique.com>
In-Reply-To: <5424156C.8080602@eas.gatech.edu>
References: <5424156C.8080602@eas.gatech.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le Thu, 25 Sep 2014 09:15:24 -0400
MJ Jenkins <mack.jenkins@eas.gatech.edu> écrivait:

> The problem comes in when the user on the Mac writes files to the NFS 
> share.  On the RHEL side the files are owned by user root and group 
> nfsnobody.  Has anyone else run into this issue?  I'm not sure if the 
> issue is how I am exporting the share to the Mac, or how I have the 
> share mounted on the Mac.

Without the content of your /etc/exports, it's impossible to know
what's happening. Mac behave like regular NFS clients. Maybe you have
"all_squash,anonuid=0,anongid=5" in your export parameter, maybe it's
something else entirely.

-- 
------------------------------------------------------------------------
Emmanuel Florac     |   Direction technique
                    |   Intellique
                    |	<eflorac@intellique.com>
                    |   +33 1 78 94 84 02
------------------------------------------------------------------------
