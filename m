Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:54050 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754846Ab2IZLqB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Sep 2012 07:46:01 -0400
Date: Wed, 26 Sep 2012 07:45:54 -0400
From: Jim Rees <rees@umich.edu>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Orion Poplawski <orion@cora.nwra.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Any way to allow setuid daemon to access krb5 automounted nfs
 directories?
Message-ID: <20120926114554.GA7683@umich.edu>
References: <5061DF69.8030606@cora.nwra.com>
 <20120925175025.GA8020@umich.edu>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908FE99CE@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908FE99CE@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond wrote:

  > -----Original Message-----
  > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
  > owner@vger.kernel.org] On Behalf Of Jim Rees
  > Sent: Tuesday, September 25, 2012 1:50 PM
  > To: Orion Poplawski
  > Cc: linux-nfs@vger.kernel.org
  > Subject: Re: Any way to allow setuid daemon to access krb5 automounted
  > nfs directories?
  >
  > But I hope you're not planning to deliver mail over nfs. I think that would be a
  > mistake.
  
  What's wrong with that? Delivering and serving up email is a fairly common
  use-case for NFS.

Nothing against spamd or NFS in particular.  It's just that some mailers
assume the file system is a local disk and are not prepared for the kinds of
failures you can get over a network.
