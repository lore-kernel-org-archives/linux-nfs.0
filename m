Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:51830 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758998Ab3BGQlo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2013 11:41:44 -0500
Date: Thu, 7 Feb 2013 11:41:24 -0500
From: Jim Rees <rees@umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 2/2] nfsd: keep a checksum of the first 256 bytes of
 request
Message-ID: <20130207164124.GA4522@umich.edu>
References: <1360248701-23963-1-git-send-email-jlayton@redhat.com>
 <1360248701-23963-3-git-send-email-jlayton@redhat.com>
 <DF2DA489-3D72-4DBF-8C65-1B7DA9866B63@oracle.com>
 <20130207160032.GF3222@fieldses.org>
 <7AE3520E-0F1E-4BDF-9977-B110180E99E3@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <7AE3520E-0F1E-4BDF-9977-B110180E99E3@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:

  > 
  >> I'm wondering if a simpler checksum might be just as useful but less
  >> costly to compute.
  > 
  > What would be an example of a simpler checksum?
  
  The same one TCP uses, like a simple additive sum, or an XOR.  Is a
  heavyweight checksum needed because checksums generated with a simple
  function are more likely to collide?

At least CRC isn't as bad as a crypto checksum like md5. Those are often
misused when what's really wanted is just a simple guard against accidental
corruption. In this case I'd go with the tcp checksum, which I think has an
api and even an accelerated implementation depending on the machine arch,
although I can't find it right now.
