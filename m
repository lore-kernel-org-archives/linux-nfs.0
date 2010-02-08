Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27005 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751235Ab0BHXNN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Feb 2010 18:13:13 -0500
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH 6/6] RPC: adjust timeout for connect, bind, restablish so that they sensitive to the major time out value
Date: Mon, 8 Feb 2010 15:13:08 -0800
Message-ID: <B9364369CA66BF45806C2CD86EAB8BA605209474@SACMVEXC3-PRD.hq.netapp.com>
In-Reply-To: <4B705B63.8060604@oracle.com>
References: <1265155576-7618-1-git-send-email-batsakis@netapp.com> <1265155576-7618-2-git-send-email-batsakis@netapp.com> <1265155576-7618-3-git-send-email-batsakis@netapp.com> <1265155576-7618-4-git-send-email-batsakis@netapp.com> <1265155576-7618-5-git-send-email-batsakis@netapp.com> <1265155576-7618-6-git-send-email-batsakis@netapp.com> <1265155576-7618-7-git-send-email-batsakis@netapp.com> <4B6C7BCA.2040806@oracle.com> <383F4881-BD88-4155-B605-4D24F5B05BDD@netapp.com> <4B6C9FA7.2010702@oracle.com> <77EBFB14-A6B6-41DC-90DC-7A00548DFAEA@netapp.com> <4B6CB3C7.8070001@oracle.com> <B9364369CA66BF45806C2CD86EAB8BA60259D23D@SACMVEXC3-PRD.hq.netapp.com> <4B6E0EF5.70307@oracle.com> <2CDC4373-10AD-4F84-BA44-3C2106D590BE@netapp.com> <4B705B63.8060604@oracle.com>
From: "Batsakis, Alexandros" <Alexandros.Batsakis@netapp.com>
To: "Chuck Lever" <chuck.lever@oracle.com>
Cc: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



> -----Original Message-----
> From: Chuck Lever [mailto:chuck.lever@oracle.com]
> Sent: Monday, February 08, 2010 10:44 AM
> To: Batsakis, Alexandros
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: [PATCH 6/6] RPC: adjust timeout for connect, bind,
> restablish so that they sensitive to the major time out value
> 
> >
> > Oh OK. Maybe then it's a reasonable workaround to the reconnection
> > policy changes. I think though that the rest of the changes wrt the
> > major timeout are still valid. Also IMHO the max of 5min seems a
lot,
> > especially for operations that are state-oriented like in v4.0 and
> v4.1.
> 
> I'm not averse to reducing the maximum reconnect delay to something
> like
> 60 seconds.  This might even be an acceptable work around for some of
> the issues you've raised.  Additional illumination of current
reconnect
> behavior may find that it no longer behaves as expected in the quick
> server reboot cases, and that also should be addressed.
> 

OK I agree that then I could only change the rest of the timeout values
to something that is in accordance with the NFS timeout and leave the
reconnection policy as it is. This is also acceptable because the
connect_timeout supersedes the reestablish_timeout and the task can
return while the connect_worker will retry to reestablish the
connection. 
AFACIS though the last point brings up another issue with the current
design as a new task would wait for a connection establishment for
XS_TCP_CONN_TO that is << XS_TCP_MAX_REEST_TO, so it may return (up to
XS_TCP_MAX_REEST_TO/XS_TCP_CONN_TO) times without even trying to
reconnect. Am I missing something ?

> However, the fact that _all_ NFSv4 state-changing operations now have
> additional delivery constraints makes this an issue larger than RENEWD
> (which is the subject line of your original postings).  IMO sunrpc.ko
> is
> not currently prepared to handle that kind of timing constraint
> adequately.  Adjusting the retransmit behavior is simply not
sufficient
> to address these problems (and perhaps it is even orthogonal to them).
> 
> --

Hm I am not sure. First, by making the RPC layer's queuing sensitive to
the timeout value and by forcing the timeout to be <= lease time we
ensure that operations will return to the NFS layer within the specified
time limits. Also, this doesn't have to be a strict requirement: forcing
state operations (except async RENEWs and SEQUENCEs) to be executed
timely is more of an optimization rather than a correctness requirement.
You are right though that I should think whether this will affect v2/v3.

Anyway, your feedback was very helpful. I ll resend patch 6/6 and we can
take it from there.

-alexandros


> chuck[dot]lever[at]oracle[dot]com
