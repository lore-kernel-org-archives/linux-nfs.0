Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:51087 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755134Ab3CSOlo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2013 10:41:44 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 10/11] NFSv4.1: Enable open-by-filehandle
Date: Tue, 19 Mar 2013 14:41:42 +0000
Message-ID: <1363704100.7515.12.camel@leira.trondhjem.org>
References: <1363698463-3681-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1363698463-3681-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1363698463-3681-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1363698463-3681-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1363698463-3681-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1363698463-3681-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1363698463-3681-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1363698463-3681-10-git-send-email-Trond.Myklebust@netapp.com>
	 <20130319140901.GB7912@fieldses.org>
	 <1363702570.7515.6.camel@leira.trondhjem.org>
	 <20130319143236.GD7912@fieldses.org>
In-Reply-To: <20130319143236.GD7912@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-03-19 at 10:32 -0400, J. Bruce Fields wrote:
> (Sorry for the digression, I was just trying to decide whether I can get
> away with turning on 4.1 by default before implementing SP4_MACH_CRED or
> GSS on the backchannel....)

If you don't, could you please at least offer up a module parameter that
allows me to do that? The current thing is a PITA, since it isn't
supported by any distro scripts, and it requires you to switch off the
server in order to change the version pseudofile contents.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
