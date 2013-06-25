Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:35347 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752807Ab3FYSw4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 14:52:56 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] NFSv4.1 Do not overwrite negotiated session sizes
Date: Tue, 25 Jun 2013 18:52:53 +0000
Message-ID: <1372186349.5968.45.camel@leira.trondhjem.org>
References: <1372185454-1888-1-git-send-email-andros@netapp.com>
	 <1372185454-1888-2-git-send-email-andros@netapp.com>
In-Reply-To: <1372185454-1888-2-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-06-25 at 14:37 -0400, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> nfs4_init_session is called after CREATE_SESSION has set the ca_maxrequestsize
> and ca_maxresponsesize values obtained from the server.

It had better not be, otherwise the values of
session->fc_target_max_rqst_sz and session->fc_target_max_resp_sz in
nfs4_init_channel_attrs() make no sense.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
