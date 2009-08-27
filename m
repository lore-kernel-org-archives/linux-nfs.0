From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] svcgss: reply AUTH_BADCRED to RPCSEC_GSS with unkown
	services
Date: Thu, 27 Aug 2009 17:09:37 -0400
Message-ID: <20090827210937.GD11721@fieldses.org>
References: <4A77FF18.4040804@cn.fujitsu.com> <20090825214002.GD32708@fieldses.org> <4A94831F.8060508@cn.fujitsu.com> <20090826205705.GA22723@fieldses.org> <4A95EE2B.60108@cn.fujitsu.com> <20090827162623.GD7055@fieldses.org> <20090827210530.GC11721@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35250 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752716AbZH0VJh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Aug 2009 17:09:37 -0400
In-Reply-To: <20090827210530.GC11721@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 27, 2009 at 05:05:30PM -0400, bfields wrote:
> On Thu, Aug 27, 2009 at 12:26:23PM -0400, bfields wrote:
> > On Thu, Aug 27, 2009 at 10:23:39AM +0800, Wei Yongjun wrote:
> > > Hi J. Bruce Fields,
> > > 
> > > J. Bruce Fields wrote:
> > > > On Wed, Aug 26, 2009 at 08:34:39AM +0800, Wei Yongjun wrote:
> > > >   
> > > >> J. Bruce Fields wrote:
> > > >>     
> > > >>> On Tue, Aug 04, 2009 at 05:27:52PM +0800, Wei Yongjun wrote:
> > > >>>   
> > > >>>       
> > > >>>> When RPC messages is received with RPCSEC_GSS, and if the RPCSEC_GSS
> > > >>>> include unkown services (not RPC_GSS_SVC_NONE, RPC_GSS_SVC_INTEGRITY
> > > >>>> and RPC_GSS_SVC_PRIVACY), the response is considered as AUTH_BADCRED
> > > >>>> in svcauth_gss_accept(), but the response be drop by
> > > >>>> svcauth_gss_release(). I think response with AUTH_BADCRED is correct
> > > >>>> one. So this patch fixed it.
> > > >>>>     
> > > >>>>         
> > > >>> Thanks!  How did you find this?  (And how did you test the result?)
> > > >>>   
> > > >>>       
> > > >> I test this used newpynfs, the GSS8 item test for this.
> > > >> #./testserver.py nfsserver:/ --security=krb5 GSS8
> > > >>     
> > > >
> > > > Oh, OK--I thought I'd been running the pynfs gss tests, but now I see
> > > > that I haven't been; I've fixed my test scripts....  Thanks!--b.
> > > >   
> > > 
> > > Did you test the test case for write? In the old kernel, there was only one
> > > test case WRT5 is FAILURE, but in current kernel, the test cases after
> > > WRT5 are all fail, the result like the following:
> > > WRT1     st_write.testSimpleWrite                                 : PASS
> > > WRT1b    st_write.testSimpleWrite2                                : PASS
> > > WRT2     st_write.testStateidOne                                  : PASS
> > > WRT3     st_write.testWithOpen                                    : PASS
> > > WRT4     st_write.testNoData                                      : PASS
> > > WRT5     st_write.testLargeData                                   : FAILURE
> > >            timed out
> > 
> > I'm not seeing exactly this, but am seeing timeouts in other tests now
> > that I'm running pynfs tests over gss--it may have the same root cause.
> > Unfortunately, your patch doesn't seem to fix the failures I'm seeing.
> > 
> > > WRT6a    st_write.testLink                                        : FAILURE
> > >            timed out
> > > WRT6c    st_write.testChar                                        : FAILURE
> > >            timed out
> > > WRT6d    st_write.testDir                                         : FAILURE
> > >            timed out
> > > WRT6f    st_write.testFifo                                        : FAILURE
> > >            timed out
> > > WRT6s    st_write.testSocket                                      : FAILURE
> > >            timed out
> > > WRT7     st_write.testNoFh                                        : FAILURE
> > >            timed out
> > > WRT8     st_write.testOpenMode                                    : FAILURE
> > >            timed out
> > > WRT9     st_write.testShareDeny                                   : FAILURE
> > >            timed out
> > > WRT10    st_write.testBadStateid                                  : FAILURE
> > >            timed out
> > > WRT11    st_write.testStaleStateid                                : FAILURE
> > >            timed out
> > > WRT12    st_write.testOldStateid                                  : FAILURE
> > >            timed out
> > > 
> > > Case WRT5 fail because the RPC TCP fragment issue. But the rest test
> > > cases are fail seems after this patch:
> > >    svc: Move close processing to a single place
> > >   
> > > http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commitdiff;h=d7979ae4a050a45b78af51832475001b68263d2a
> > > 
> > > Old kernel will close the xprt after receive error. But new code is
> > > check before
> > > receive, and can nerver enter the check for CLOSE state.
> > > 
> > > Can you have a look at this patch?
> > 
> > OK, thanks, that makes sense.  I won't to investigate a little more
> > before applying, though.
> 
> Bah, it looks like I was just seeing a disagreement between pynfs and
> nfsd about whether the sequence number should be incremented in the case
> of an otherwise correct packet with a bad gss_service, which means that
> after running GSS8, any subsequent requests with the same context are
> dropped (and time out).

(Your patch still looks fine to me, though--applied).

--b.
