Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shiva144.upmc.fr ([134.157.0.144]:62203 "EHLO shiva.upmc.fr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753430Ab2FWLSh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 23 Jun 2012 07:18:37 -0400
Message-ID: <4FE5A5FB.3080608@upmc.fr>
Date: Sat, 23 Jun 2012 13:18:19 +0200
From: Bernard Pidoux <bernard.pidoux@upmc.fr>
MIME-Version: 1.0
To: Francois Romieu <romieu@fr.zoreil.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        linux-nfs@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: rpc_pipefs kernel panic kernel 3.4.3
References: <F77FADB4-0415-4945-AC03-CEE36F2FEB08@upmc.fr> <4FE4DB31.4000601@free.fr> <4FE4F7FA.4000604@free.fr> <20120623061353.GA18625@electric-eye.fr.zoreil.com>
In-Reply-To: <20120623061353.GA18625@electric-eye.fr.zoreil.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I confirm that 3.3.8 is fine.
NULL pointer seems to have been introduced in 3.4 rpc_pipefs if I am right.

Bernard

