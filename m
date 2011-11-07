Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:50557 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932503Ab1KGOpL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Nov 2011 09:45:11 -0500
Subject: Re: rpcbind -h
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20111106155844.GA1790@umich.edu>
Date: Mon, 7 Nov 2011 09:44:59 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <3096DDEC-48D3-423A-B674-160B8DA59DE2@oracle.com>
References: <20111106155844.GA1790@umich.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 6, 2011, at 10:58 AM, Jim Rees wrote:

> Is there some good reason why the rpcbind '-h' option (bind to given
> address) applies only to the udp listening socket and not to the tcp socket?

Yes.  See the mail archives.  I believe we've discussed this thoroughly within the past six months to a year.  If there's any bug here, it's that "-h" is not well documented.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




