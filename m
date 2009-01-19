From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Tue, 20 Jan 2009 09:58:47 +1100
Message-ID: <497505A7.1070600@melbourne.sgi.com>
References: <49711BDF.3010605@melbourne.sgi.com> <x49ab9ntlpp.fsf@segfault.boston.devel.redhat.com> <20090119194958.GA3108@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Moyer <jmoyer@redhat.com>, Steve Dickson <SteveD@redhat.com>,         Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,         Linux NFS Mailing list <linux-nfs@vger.kernel.org>,         SystemTAP <systemtap@sources.redhat.com>
To: Jason Baron <jbaron@redhat.com>
Return-path: <systemtap-return-10936-gls-systemtap=m.gmane.org@sourceware.org>
In-Reply-To: <20090119194958.GA3108@redhat.com>
List-Unsubscribe: <mailto:systemtap-unsubscribe-gls-systemtap=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:systemtap-subscribe@sourceware.org>
List-Post: <mailto:systemtap@sourceware.org>
List-Help: <mailto:systemtap-help@sourceware.org>, <http://sourceware.org/lists.html#faqs>
Sender: systemtap-owner@sourceware.org
List-ID: <linux-nfs.vger.kernel.org>

Jason Baron wrote:
> On Mon, Jan 19, 2009 at 09:27:30AM -0500, Jeff Moyer wrote:
>   
>> Greg Banks <gnb@melbourne.sgi.com> writes:
>>
>>     
>>> Steve Dickson wrote:
>>>       
>>>> So the ultimate goal would be to replace all the dprintks with trace points
>>>> but still be able to enable them through the rpcdebug command
>>>>         
>>> I have a patch which changes the definition of the dprintk() macro (but
>>> *not* dprintk() callsites) to allow enabling and disabling individual
>>> dprintk() statements through a /proc/ interface.  Would you be
>>> interested in that?
>>>       
>> That sounds like duplicated work.  How does it differ from Jason Baron's
>> dynamic printk patches (which I believe are now upstream)?
>>
>> Cheers,
>> Jeff
>>     
>
> indeed. I've implemented a solution in a very similar problem space
> which is now upstream, see:
>
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=346e15beb5343c2eb8216d820f2ed8f150822b08;hp=33376c1c043c05077b4ac79c33804266f6c45e49
>
>   
Meh, I've been spending too much time in insular SLES10 land.

> One of the core fundamental differences that I see is that 'dprintk'
> checks a global variable per dprintk line.
Yes, this is a key design feature.

The problem I was addressing was debugging NFS/RDMA.  That transport had
at the time no way to do any kind of network capture, and dprintks were
the *only* debugging mechanism.  So the code is absolutely riddled with
dprintks, some enormous and some in key performance paths.  This means
that enabling dprintks on a per-module basis would a) overflow the
dprintk buffer in a few milliseconds and b) perturb the time behaviour
of the code sufficiently to mask the problem you were trying to diagnose.

Later it became apparent that this would also be very useful for field
support folks.

>  Whereas, 'dynamic printk'
> assigns each module a set of bits in a *single* global variable. 
This seems to be more or less equivalent to the mechanism that
nfs/sunrpc use today, i.e. quite coarse grained.
> The
> idea was that if you have thousands of these debug lines throughout the
> kernel, I wanted to have a small footprint.
>   

Indeed.  For me,debuggability and supportability are far more important.
> The per-dprintk granularity could be implemented on top of the
> per-module approach that i've taken. That is, each dprintk statement
> could activate the module that its associated with when its activated.
> Then, a further per-line variable could be checked.
>   

Yes.  Or you could make the per-line variables the only state kept and
do the equivalent of

echo "module sunrpc +p" > /proc/dprintk

when the sysadmin does

echo "set enabled=1 <module_name>" > dynamic_printk/modules

i.e. run a query over the dprintk records and mark all the ones that
match the module.
> We should probably move this discussion to lkml, since this probably
> should involve a wider audience. Perhaps, you can re-post your patchset
> there?
>
>
>   
Ok, will do.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
