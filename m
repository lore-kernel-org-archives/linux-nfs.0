Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45645 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753322AbbFHUt6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 16:49:58 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH 3/6] SUNRPC: Clean up bc_send()
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150608204734.GA27887@fieldses.org>
Date: Mon, 8 Jun 2015 16:52:54 -0400
Cc: "William A. (Andy) Adamson" <androsadamson@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <BAD55198-804F-4B00-8A79-080FB694343D@oracle.com>
References: <1433453213-13466-1-git-send-email-trond.myklebust@primarydata.com> <1433453213-13466-2-git-send-email-trond.myklebust@primarydata.com> <1433453213-13466-3-git-send-email-trond.myklebust@primarydata.com> <CAHVgHyWz-dKX-6TbRCYRBp7b2uV2-kCd7U63sHd5ZKZKr6e7aw@mail.gmail.com> <B30A41CC-EADC-4738-8FDF-E8B03AAA48FC@oracle.com> <20150608204734.GA27887@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 8, 2015, at 4:47 PM, bfields@fieldses.org wrote:

> On Fri, Jun 05, 2015 at 12:02:11PM -0400, Chuck Lever wrote:
>> 
>> On Jun 5, 2015, at 11:50 AM, Andy Adamson <androsadamson@gmail.com> wrote:
>> 
>>> On Thu, Jun 4, 2015 at 5:26 PM, Trond Myklebust
>>> <trond.myklebust@primarydata.com> wrote:
>>>> From: Chuck Lever <chuck.lever@oracle.com>
>>>> 
>>>> Clean up: Merge bc_send() into bc_svc_process().
>>>> 
>>>> Note: even thought this touches svc.c, it is a client-side change.
>>>> 
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>>>> ---
>>>> include/linux/sunrpc/bc_xprt.h |  1 -
>>>> net/sunrpc/Makefile            |  2 +-
>>>> net/sunrpc/bc_svc.c            | 63 ------------------------------------------
>>>> net/sunrpc/svc.c               | 33 ++++++++++++++++------
>>>> 4 files changed, 26 insertions(+), 73 deletions(-)
>>>> delete mode 100644 net/sunrpc/bc_svc.c
>>>> 
>>>> diff --git a/include/linux/sunrpc/bc_xprt.h b/include/linux/sunrpc/bc_xprt.h
>>>> index 2ca67b55e0fe..8df43c9f11dc 100644
>>>> --- a/include/linux/sunrpc/bc_xprt.h
>>>> +++ b/include/linux/sunrpc/bc_xprt.h
>>>> @@ -37,7 +37,6 @@ void xprt_complete_bc_request(struct rpc_rqst *req, uint32_t copied);
>>>> void xprt_free_bc_request(struct rpc_rqst *req);
>>>> int xprt_setup_backchannel(struct rpc_xprt *, unsigned int min_reqs);
>>>> void xprt_destroy_backchannel(struct rpc_xprt *, unsigned int max_reqs);
>>>> -int bc_send(struct rpc_rqst *req);
>>>> 
>>>> /*
>>>> * Determine if a shared backchannel is in use
>>>> diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
>>>> index 15e6f6c23c5d..1b8e68d0e690 100644
>>>> --- a/net/sunrpc/Makefile
>>>> +++ b/net/sunrpc/Makefile
>>>> @@ -15,6 +15,6 @@ sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
>>>>           sunrpc_syms.o cache.o rpc_pipe.o \
>>>>           svc_xprt.o
>>>> sunrpc-$(CONFIG_SUNRPC_DEBUG) += debugfs.o
>>>> -sunrpc-$(CONFIG_SUNRPC_BACKCHANNEL) += backchannel_rqst.o bc_svc.o
>>>> +sunrpc-$(CONFIG_SUNRPC_BACKCHANNEL) += backchannel_rqst.o
>>>> sunrpc-$(CONFIG_PROC_FS) += stats.o
>>>> sunrpc-$(CONFIG_SYSCTL) += sysctl.o
>>>> diff --git a/net/sunrpc/bc_svc.c b/net/sunrpc/bc_svc.c
>>>> deleted file mode 100644
>>>> index 15c7a8a1c24f..000000000000
>>>> --- a/net/sunrpc/bc_svc.c
>>>> +++ /dev/null
>>>> @@ -1,63 +0,0 @@
>>>> -/******************************************************************************
>>>> -
>>>> -(c) 2007 Network Appliance, Inc.  All Rights Reserved.
>>>> -(c) 2009 NetApp.  All Rights Reserved.
>>>> -
>>>> -NetApp provides this source code under the GPL v2 License.
>>>> -The GPL v2 license is available at
>>>> -http://opensource.org/licenses/gpl-license.php.
>>>> -
>>>> -THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
>>>> -"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
>>>> -LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
>>>> -A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
>>>> -CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
>>>> -EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
>>>> -PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
>>>> -PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
>>>> -LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
>>>> -NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
>>>> -SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
>>>> -
>>>> -******************************************************************************/
>>> 
>>> Why is the above being removed?
>> 
>> Hi Andy-
>> 
>> Interesting question, and IANAL.
>> 
>> Where should the boilerplate go if the below function is merged into
>> existing generic server code? I suppose we could fold the NetApp
>> copyright into the comment at the top of net/sunrpc/svc.c , but the
>> merged code is paraphrased rather than copied directly.
>> 
>> Suggestions/opinions are welcome.
> 
> I don't know, the above looks like pretty generic boilerplate, and I'd
> rather not accumulate a that kind of thing every time we move a
> significant piece of code around.  Could we compromise by adding a line
> or two to net/sunrpc/svc.c following the existing convention there?
> ("backchannel implementation originally (c) 2007 Network Appliance and
> (c) 2009 Netapp", or similar?)  Not a lawyer either, just looking for a
> way to keep it both honest and concise….

Yes, that’s exactly what I was thinking. Sorry I wasn’t clear.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



