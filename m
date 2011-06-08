Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:60256 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956Ab1FHSgJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2011 14:36:09 -0400
Date: Wed, 8 Jun 2011 14:36:08 -0400
From: Jim Rees <rees@umich.edu>
To: greearb@candelatech.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils:  Support binding to source address.
Message-ID: <20110608183608.GA3513@merit.edu>
References: <1307554748-31757-1-git-send-email-greearb@candelatech.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1307554748-31757-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

greearb@candelatech.com wrote:

  +	if (local_ip && local_ip->is_set) {
  +		sa = (struct sockaddr *)(char *)(&local_ip->addr);
  +		salen = local_ip->addrlen;
  +	} else {
  +		switch (family) {
  +		case AF_INET:
  +			sa = (struct sockaddr *)(char *)&sin;
  +			salen = sizeof(sin);
  +			break;
  +		case AF_INET6:
  +			sa = (struct sockaddr *)(char *)&sin6;
  +			salen = sizeof(sin6);
  +		default:
  +			break;
  +		}

Are the double casts actually necessary?  And if so, shouldn't the inner one
be (void *)?
