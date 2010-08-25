Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:54284 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751392Ab0HYXg4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Aug 2010 19:36:56 -0400
Date: Thu, 26 Aug 2010 09:36:48 +1000
From: Neil Brown <neilb@suse.de>
To: Peng Yu <pengyu.ut@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Does the machine need to be restarted after RPCNFSDCOUNT in
 /etc/default/nfs-kernel-server (ubuntu) is edited?
Message-ID: <20100826093648.26d03c1c@notabene>
In-Reply-To: <AANLkTi=8rnEtOikhVqsH5Pj1QUhc5MiSHMfncZO1xCem@mail.gmail.com>
References: <AANLkTi=8rnEtOikhVqsH5Pj1QUhc5MiSHMfncZO1xCem@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 25 Aug 2010 15:02:14 -0500
Peng Yu <pengyu.ut@gmail.com> wrote:

> Hi,
> 
> I changed the value of RPCNFSDCOUNT in /etc/default/nfs-kernel-server
> (ubuntu). Do I need to restart the machine?
> 
> Or I need to restart nfsd? If so, would you please let me know how to
> restart nfsd?
> 

Easiest thing to do is simply

   rpc.nfsd $NUMBER

it will change the number of running threads to match the number that you
give.

NeilBrown
