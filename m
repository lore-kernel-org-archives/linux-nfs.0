Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:13806 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691Ab3FYTiB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 15:38:01 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] NFSv4.1 Do not overwrite negotiated session sizes
Date: Tue, 25 Jun 2013 19:37:59 +0000
Message-ID: <1372189073.5968.51.camel@leira.trondhjem.org>
References: <1372185454-1888-1-git-send-email-andros@netapp.com>
	 <1372185454-1888-2-git-send-email-andros@netapp.com>
	 <1372186349.5968.45.camel@leira.trondhjem.org>
	 <4DF3A886-7DBA-4D8A-8111-29C1240C9487@netapp.com>
In-Reply-To: <4DF3A886-7DBA-4D8A-8111-29C1240C9487@netapp.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-06-25 at 19:05 +0000, Adamson, Andy wrote:
> On Jun 25, 2013, at 2:52 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
>  wrote:
> 
> > On Tue, 2013-06-25 at 14:37 -0400, andros@netapp.com wrote:
> >> From: Andy Adamson <andros@netapp.com>
> >> 
> >> nfs4_init_session is called after CREATE_SESSION has set the ca_maxrequestsize
> >> and ca_maxresponsesize values obtained from the server.
> > 
> > It had better not be, otherwise the values of
> > session->fc_target_max_rqst_sz and session->fc_target_max_resp_sz in
> > nfs4_init_channel_attrs() make no sense.
> 
> Well, it does. Shall I move the nfs4_init_session call to before nfs4_init_channel_attrs?
> 

Either that, or change nfs4_init_channel_attrs() to always use
NFS_MAX_FILE_IO_SIZE. Right now, the code is just confused (and very
confusing).


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
