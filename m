Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:35607 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753812Ab2E0CdS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 May 2012 22:33:18 -0400
References: <1338057600-11130-1-git-send-email-Trond.Myklebust@netapp.com> <1338057600-11130-2-git-send-email-Trond.Myklebust@netapp.com> <1338057600-11130-3-git-send-email-Trond.Myklebust@netapp.com> <1338057600-11130-4-git-send-email-Trond.Myklebust@netapp.com> <1338057600-11130-5-git-send-email-Trond.Myklebust@netapp.com> <1338057600-11130-6-git-send-email-Trond.Myklebust@netapp.com> <1338057600-11130-7-git-send-email-Trond.Myklebust@netapp.com> <1338057600-11130-8-git-send-email-Trond.Myklebust@netapp.com> <8A0B2B0E-910C-4090-B3B1-DE04F8875175@oracle.com> <1338062247.2453.5.camel@lade.trondhjem.org>
In-Reply-To: <1338062247.2453.5.camel@lade.trondhjem.org>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=utf-8
Message-Id: <28096DDE-B34F-41F5-8A46-A32A01F84571@oracle.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v2 8/9] NFSv4.1: Add DESTROY_CLIENTID
Date: Sat, 26 May 2012 22:34:54 -0400
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 26, 2012, at 3:57 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Sat, 2012-05-26 at 15:43 -0400, Chuck Lever wrote:
>> On May 26, 2012, at 2:39 PM, Trond Myklebust wrote:
>> 
>>> Ensure that we destroy our lease on last unmount
>> 
>> So why aren't we using DESTROY_CLIENTID in nfs4_reset_all_state() ?
> 
> They are different operations.
> 
> In nfs4_reset_all_state we're declaring a client reboot: this means that
> we want the server to release all old state associated with this client
> id on the server because we're trying to establish a new client id.
> 
> DESTROY_CLIENTID is there in order to destroy a client id that is no
> longer in use. According to Section 2.4.2 of RFC5661 that means that it
> "cannot be used if there are sessions associated with the client ID, or
> state with an unexpired lease". In fact the server is required to reject
> our DESTROY_CLIENTID call if it thinks we still hold state.
> 
> So while we could possibly call DESTROY_CLIENTID after declaring the
> client reboot (but what would be the point?), we can't use it as a
> substitute for doing so in nfs4_reset_all_state...

Thanks, that makes sense to me.

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
> N�����r��y���b�X��ǧv�^�)޺{.n�+����{���"��^n�r��z���h����&���G���h�(�階�ݢj"���m�����z�ޖ���f���h���~�m�
