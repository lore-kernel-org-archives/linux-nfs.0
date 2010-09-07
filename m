Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35221 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758079Ab0IGS7c convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 14:59:32 -0400
Subject: Re: [PATCH 02/03]: sunrpc: make auth_hashtable_size param mode 0444
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Miquel van Smoorenburg <mikevs@xs4all.net>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20100822183109.GB26607@xs4all.net>
References: <20100822182848.GA26590@xs4all.net>
	 <20100822183109.GB26607@xs4all.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Sep 2010 14:58:52 -0400
Message-ID: <1283885932.2788.69.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 2010-08-22 at 20:31 +0200, Miquel van Smoorenburg wrote:
> The auth_hashtable_size parameter shows up in
> /sys/module/sunrpc/parameters with mode 0644. However the hashtables
> are allocated when the module is loaded, and changing the parameter
> afterwards doesn't do much. So make it read-only.

The above observation is only correct for AUTH_SYS. The reason for
making the mode 0644 was to allow users to change the value after
loading if they want to use RPCSEC_GSS.

Cheers
  Trond
