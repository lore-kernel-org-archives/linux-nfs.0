From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 1/1] silence-call-timeout-printk
Date: Fri, 28 Mar 2008 11:57:14 -0400
Message-ID: <EXNANE01WtIIZS2TRqf000001da@exnane01.hq.netapp.com>
References: <1206643752-11132-1-git-send-email-aglo@umich.edu>
 <20080327195445.GI32540@fieldses.org>
 <1206648229.15396.2.camel@heimdal.trondhjem.org>
 <20080327202331.GJ32540@fieldses.org>
 <EXNANE01kO22ZhCl8ai000001cd@exnane01.hq.netapp.com>
 <20080327205311.GL32540@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	Olga Kornievskaia <aglo@umich.edu>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36151 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753680AbYC1P5W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Mar 2008 11:57:22 -0400
In-Reply-To: <20080327205311.GL32540@fieldses.org>
References: <1206643752-11132-1-git-send-email-aglo@umich.edu>
 <20080327195445.GI32540@fieldses.org>
 <1206648229.15396.2.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
 <20080327202331.GJ32540@fieldses.org>
 <EXNANE01kO22ZhCl8ai000001cd-kboziUmgGqYSZCGxjG3uujkOHZLvdrmu@public.gmane.org>
 <20080327205311.GL32540@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 04:53 PM 3/27/2008, J. Bruce Fields wrote:
>  (It's pretty easy for callbacks to
>fail, especially the initial probe of the callback channel.  I don't
>want to spam the server's logs about that.)

Agree. The approach sounds good. Besides, the 4.1 session will
often avoid the whole situation, by sharing the channel.

Tom.

