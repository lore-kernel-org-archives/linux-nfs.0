From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Sat, 24 Jan 2009 09:18:07 +1100
Message-ID: <497A421F.2010501@melbourne.sgi.com>
References: <5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com>
	<497757D1.7090908@RedHat.com>
	<F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>
	<49777988.6010401@RedHat.com>
	<A3A2C7E0-3403-4863-A670-862886AF9EC9@oracle.com>
	<4977A385.8000406@melbourne.sgi.com>
	<20090121225619.GI4295@fieldses.org> <497897F5.9030005@RedHat.com>
	<20090122164503.GC13129@fieldses.org>
	<4978F91C.4090208@melbourne.sgi.com>
	<20090123180959.GA32186@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	SystemTAP <systemtap@sources.redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090123180959.GA32186@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Fri, Jan 23, 2009 at 09:54:20AM +1100, Greg Banks wrote:
>   
>> J. Bruce Fields wrote:
>>     
>>> On Thu, Jan 22, 2009 at 10:59:49AM -0500, Steve Dickson wrote:
>>>   
>>>       
>>>> J. Bruce Fields wrote:
>>>>     
>>>>
>>>> Interesting.... Store something like a reason code (similar to what they have
>>>> in he Kerberos)
>>>>     
>>>>         
>>> Maybe.
>>>
>>>   
>>>       
>>>> in somewhere in the proc file system? 
>>>>     
>>>>         
>>> But then I don't know how you'd associate it with a particular mount
>>> attempt.
>>>
>>>
>>>   
>>>       
>> You could do something truly awful like add a new code in the unused
>> bits of the errno value returned from mount.  It would confuse an
>> unmodified userspace, but reporting "Unknown Error" isn't much less
>> useful than "I/O Error".
>>     
>
> There must be cases where the existing error gives us some information,
> but not as much as we'd like, so the "Unknown Error" could be a step
> backwards for unmodified userspace.  An extra mount option (normally
> hidden from the user) could be used to tell the kernel that the
> application doing the mount was capable of handling the new error codes.
> Ugh.
>
>
>   
Ugh is right.

On further thought, you could use the extra mount option to enable a
behaviour where the kernel would format into the mount options buffer a
string describing the reasons for the mount failure.  If the option
weren't present the kernel could emit that same message via printk().

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
