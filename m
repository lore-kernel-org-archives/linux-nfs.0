From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 3/8] SUNRPC: Use RPC procedure name in call_verify
Date: Wed, 21 May 2008 12:02:45 -0400
Message-ID: <483447A5.8000802@redhat.com>
References: <20080520202108.3851.7464.stgit@ellison.1015granger.net> <20080520202941.3851.61861.stgit@ellison.1015granger.net> <1211318498.26809.13.camel@localhost> <DF95EE8C-4F20-4B4A-9967-9AD354196D4D@oracle.com> <48341218.10009@redhat.com> <RTPCLUEXC1-PRDQrwFN00000141@RTPMVEXC1-PRD.hq.netapp.com> <483417CE.1070308@redhat.com> <E3DF41A5-5DBA-42CE-ADE2-FAE8AC5E4722@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	linux-nfs@vger.kernel.org
To: Robert Gordon <Robert.Gordon-UdXhSnd/wVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56274 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763100AbYEUQFI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 May 2008 12:05:08 -0400
In-Reply-To: <E3DF41A5-5DBA-42CE-ADE2-FAE8AC5E4722-UdXhSnd/wVw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Robert Gordon wrote:
>
> This being an accepted practice -- as opposed to a clearly
> defined requirement in a spec someplace ?? 

You know, I don't know whether the RPC specification clearly
indicates that procedure, 0, is the NULL procedure.  It just
seems to be accepted practice and assumptions have been made
that procedure, 0, is the NULL procedure and also does not
require any special authentication.

The NULL_PROC is used as a "ping" sort of procedure by things
like rpcinfo, the NFS mount command, etc.

       ps
