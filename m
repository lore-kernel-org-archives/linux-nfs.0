From: =?ISO-8859-1?Q?Carlos_Andr=E9?= <candrecn@gmail.com>
Subject: Re: AutoFS+NFSv4 server down = LOOOOONG timeout.
Date: Thu, 17 Sep 2009 09:58:45 -0300
Message-ID: <f6ce31e30909170558i184b2197ye65d7e04fd2fad17@mail.gmail.com>
References: <f6ce31e30907291021p769d8bb7jb7a13d0370b87bd6@mail.gmail.com>
	<1250555418.16878.7.camel@zeus.themaw.net>
	<f6ce31e30908240627gff0a7eeu3c884185e6324518@mail.gmail.com>
	<4A92AA43.6070304@redhat.com> <4A9649B3.7080208@redhat.com>
	<7A35D986-E872-4DBD-8619-1F29D97AC039@oracle.com>
	<1251384739.5173.7.camel@heimdal.trondhjem.org>
	<EE444BE9-552C-48EA-9F4E-CB958A8270B0@oracle.com>
	<1251385235.5173.13.camel@heimdal.trondhjem.org>
	<0823762D-BD01-4C34-B550-AEB7F838FF1A@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: Ian Kent <ikent@redhat.com>, NFS list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <0823762D-BD01-4C34-B550-AEB7F838FF1A@oracle.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Hi ppl,

any news about this problem? :)

Thanks.

2009/8/27 Chuck Lever <chuck.lever@oracle.com>:
> On Aug 27, 2009, at 11:00 AM, Trond Myklebust wrote:
>>
>> On Thu, 2009-08-27 at 10:54 -0400, Chuck Lever wrote:
>>>
>>> On Aug 27, 2009, at 10:52 AM, Trond Myklebust wrote:
>>>>
>>>> On Thu, 2009-08-27 at 10:38 -0400, Chuck Lever wrote:
>>>>>
>>>>> On Aug 27, 2009, at 4:54 AM, Ian Kent wrote:
>>>>>>
>>>>>> Ian Kent wrote:
>>>>>>>
>>>>>>> Carlos Andr=E9 wrote:
>>>>>>>>
>>>>>>>> Hi Ian,
>>>>>>>>
>>>>>>>> Thanks for patch and sorry for delay (i'm expecting receive u
>>>>>>>> reply on
>>>>>>>> bug track, not here) :)
>>>>>>>>
>>>>>>>> But, this patch doesnt worked to me like expected... =A0:(
>>>>>>>>
>>>>>>>>
>>>>>>>> Firstly I've changed "#MOUNT_WAIT=3D-1" to "MOUNT_WAIT=3D10"
>>>>>>>> and later changed "10" to "2" with same results...
>>>>>>>> (always restarting service, of course :)
>>>>>>>>
>>>>>>>> Then, tried remove "sec=3Dkrb5p", and later removed "nfs4" but i g=
ot
>>>>>>>> same results again.
>>>>>>>>
>>>>>>>> Or i'm doing something wrong?
>>>>>>>>
>>>>>>>>
>>>>>>>> [root@KSTATION areas]# automount -V
>>>>>>>>
>>>>>>>> Linux automount version 5.0.1-0.rc2.131.bz517349.1
>>>>>>>> [...]
>>>>>>>>
>>>>>>>> [root@KSTATION areas]# time ls -la testdown
>>>>>>>> ls: testedown: No such file or directory
>>>>>>>>
>>>>>>>> real =A0 =A03m9.006s
>>>>>>>> user =A0 =A00m0.002s
>>>>>>>> sys =A0 =A0 0m0.000s
>>>>>>>
>>>>>>> OK, that isn't behaving the way I expect, I'll have a look.
>>>>>>>
>>>>>>>>
>>>>>>>> LOGGING:
>>>>>>>> -----------------------------------------
>>>>>>>> Aug 24 09:23:51 KSTATION automount[20803]: mount_mount:
>>>>>>>> mount(nfs):
>>>>>>>> calling mount -t nfs4 -s -o rw,acl,sec=3Dkrb5p 1.2.3.4:/areas/
>>>>>>>> testdown
>>>>>>>> /misc/areas/testdown
>>>>>>>> Aug 24 09:27:00 KSTATION automount[20803]: mount(nfs): nfs: mount
>>>>>>>> failure 1.2.3.4:/areas/testdown on /misc/areas/testdown
>>>>>>>> Aug 24 09:27:00 KSTATION automount[20803]: ioctl_send_fail: token
>>>>>>>> =3D 91
>>>>>>>> Aug 24 09:27:00 KSTATION automount[20803]: failed to mount /misc/
>>>>>>>> areas/testdown
>>>>>>>> -----------------------------------------
>>>>>>
>>>>>> Having a look at this I suspect the reason it doesn't work as
>>>>>> expected
>>>>>> is the waitpid(2) we do after sending the TERM signal to the mount
>>>>>> process (which we have to do) is not returning. This is likely
>>>>>> because
>>>>>> the mount process isn't giving up in a shorter time as it used to.
>>>>>
>>>>> You're thinking maybe mount(2) should be as interruptible as the
>>>>> socket calls that the mount command used to do? =A0That might be
>>>>> reasonable, and I can take a look at that.
>>>>
>>>> In recent kernels, all those RPC calls should be using TASK_KILLABLE
>>>> sleep states. SIGTERM should cause them to abort, provided that some
>>>> process isn't blocking it.
>>>>
>>>> Perhaps TASK_KILLABLE could be backported to RHEL-5?
>>>
>>> That's pretty extensive, with hooks in the page cache. =A0I doubt RH
>>> would go for that.
>>
>> You don't have to add the hooks in the page cache in order to make mount
>> interruptible. You just need to replace the sigmask-manipulation in
>> net/sunrpc and fs/nfs (a.k.a. rpc_clnt_sigmask()/rpc_clnt_sigunmask())
>> with TASK_KILLABLE.
>
> That sounds like a schlep.
>
>> Alternatively, it might suffice to just turn on the 'intr' flag
>> temporarily while doing the mount path walk, and then switch it to
>> whatever default the user actually specified afterwards.
>
> That sounds easy, especially for an EL5 kernel. =A0Maybe "soft" too for t=
he
> first few requests?
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
>



-- =

Atenciosamente,
Carlos Andr=E9
LPIC-1 / LPIC-2 / CCNA / CCNP

candrecn.at.gmail.dot.com
