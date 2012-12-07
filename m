Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:56202 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751932Ab2LGXo3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Dec 2012 18:44:29 -0500
Date: Fri, 7 Dec 2012 18:44:20 -0500
From: Jim Rees <rees@umich.edu>
To: bjschuma@netapp.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] NFSD: Pass correct buffer size to rpc_ntop
Message-ID: <20121207234420.GA11001@umich.edu>
References: <1354915049-6892-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1354915049-6892-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

bjschuma@netapp.com wrote:

  From: Bryan Schumaker <bjschuma@netapp.com>
  
  I honestly have no idea where I got 129 from, but it's a much bigger
  value than the actual buffer size (INET6_ADDRSTRLEN).

128 for the number of bits in an ip6 address, plus one more for the null
terminator bit?

(yes, I'm joking, for those of you with no sense of humor)
