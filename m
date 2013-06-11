Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:55196 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755392Ab3FKLl3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jun 2013 07:41:29 -0400
Date: Tue, 11 Jun 2013 07:41:14 -0400
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH]: gssd: Fix preferred_realm option handling
Message-ID: <20130611114114.GB16756@umich.edu>
References: <20130611093403.GB27345@principal.rfc2324.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130611093403.GB27345@principal.rfc2324.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Maximilian Wilhelm wrote:

  +	 * Make sure the preferred_realm (which may have been explicitly set
  +	 * on the command line, is tried first. If nothing is found go on with
  +	 * the host and local default realm (if that hasn't already been tried).

You're missing a close paren there somewhere.
