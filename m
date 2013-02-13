Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54946 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760246Ab3BMUOT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Feb 2013 15:14:19 -0500
Message-ID: <511BF3ED.6070803@RedHat.com>
Date: Wed, 13 Feb 2013 15:13:33 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "J.Bruce Fields" <bfields@fieldses.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH nfs-utils] Call authgss_free_private_data() if library
 provides it.
References: <20130205112846.17b65602@notabene.brown>
In-Reply-To: <20130205112846.17b65602@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/02/13 19:28, NeilBrown wrote:
> librpcsecgss provides authgss_free_private_data() as a pair to
> authgss_get_private_data().  libtirpc does not - until recently.
> 
> This ommision results in authgss_destroy_context() sending an
> incorrect RPCSEC_GSS_DESTROY request when gssd calls AUTH_DESTROY().
> 
> The call has been added to libtirpc, so this patch updates nfs-utils
> to check for the presense of the function in libtirpc and to set
> HAVE_AUTHGSS_FREE_PRIVATE_DATA if it is present.
> This is also set unconditionally if librpcsecgss is used.
> 
> gssd is changed to test this value rather than HAVE_LIBTIRPC when
> chosing whether to call authgss_free_private_data().
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed... 

steved.
