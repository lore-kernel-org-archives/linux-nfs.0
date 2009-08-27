From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: AutoFS+NFSv4 server down = LOOOOONG timeout.
Date: Thu, 27 Aug 2009 11:12:22 -0400
Message-ID: <0823762D-BD01-4C34-B550-AEB7F838FF1A@oracle.com>
References: <f6ce31e30907291021p769d8bb7jb7a13d0370b87bd6@mail.gmail.com>
	<7E189B77-1139-4B16-97E5-4841B41B90C7@oracle.com>
	<4A82CE18.6020401@redhat.com>
	<f6ce31e30908120800i2cc82005s695d1097df554b58@mail.gmail.com>
	<4A82DDB1.1000109@redhat.com>
	<f6ce31e30908120940m6e9a093ayc59d7ef98e37b3d0@mail.gmail.com>
	<4A84210F.3020906@redhat.com>
	<f6ce31e30908130743l78423b52je5aaeaaf3ed1a373@mail.gmail.com>
	<f6ce31e30908130818r2ccd676ax174eb5062282a15b@mail.gmail.com>
	<1250555418.16878.7.camel@zeus.themaw.net>
	<f6ce31e30908240627gff0a7eeu3c884185e6324518@mail.gmail.com>
	<4A92AA43.6070304@redhat.com> <4A9649B3.7080208@redhat.com>
	<7A35D986-E872-4DBD-8619-1F29D97AC039@oracle.com>
	<1251384739.5173.7.camel@heimdal.trondhjem.org>
	<EE444BE9-552C-48EA-9F4E-CB958A8270B0@oracle.com>
	<1251385235.5173.13.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset="iso-8859-1"; Format="flowed"; DelSp="yes"
Cc: Ian Kent <ikent@redhat.com>, NFS list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1251385235.5173.13.camel@heimdal.trondhjem.org>
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

On Aug 27, 2009, at 11:00 AM, Trond Myklebust wrote:
> On Thu, 2009-08-27 at 10:54 -0400, Chuck Lever wrote:
>> On Aug 27, 2009, at 10:52 AM, Trond Myklebust wrote:
>>> On Thu, 2009-08-27 at 10:38 -0400, Chuck Lever wrote:
>>>> On Aug 27, 2009, at 4:54 AM, Ian Kent wrote:
>>>>> Ian Kent wrote:
>>>>>> Carlos Andr=E9 wrote:
>>>>>>> Hi Ian,
>>>>>>>
>>>>>>> Thanks for patch and sorry for delay (i'm expecting receive u
>>>>>>> reply on
>>>>>>> bug track, not here) :)
>>>>>>>
>>>>>>> But, this patch doesnt worked to me like expected...  :(
>>>>>>>
>>>>>>>
>>>>>>> Firstly I've changed "#MOUNT_WAIT=3D-1" to "MOUNT_WAIT=3D10"
>>>>>>> and later changed "10" to "2" with same results...
>>>>>>> (always restarting service, of course :)
>>>>>>>
>>>>>>> Then, tried remove "sec=3Dkrb5p", and later removed "nfs4" but i  =

>>>>>>> got
>>>>>>> same results again.
>>>>>>>
>>>>>>> Or i'm doing something wrong?
>>>>>>>
>>>>>>>
>>>>>>> [root@KSTATION areas]# automount -V
>>>>>>>
>>>>>>> Linux automount version 5.0.1-0.rc2.131.bz517349.1
>>>>>>> [...]
>>>>>>>
>>>>>>> [root@KSTATION areas]# time ls -la testdown
>>>>>>> ls: testedown: No such file or directory
>>>>>>>
>>>>>>> real    3m9.006s
>>>>>>> user    0m0.002s
>>>>>>> sys     0m0.000s
>>>>>>
>>>>>> OK, that isn't behaving the way I expect, I'll have a look.
>>>>>>
>>>>>>>
>>>>>>> LOGGING:
>>>>>>> -----------------------------------------
>>>>>>> Aug 24 09:23:51 KSTATION automount[20803]: mount_mount:
>>>>>>> mount(nfs):
>>>>>>> calling mount -t nfs4 -s -o rw,acl,sec=3Dkrb5p 1.2.3.4:/areas/
>>>>>>> testdown
>>>>>>> /misc/areas/testdown
>>>>>>> Aug 24 09:27:00 KSTATION automount[20803]: mount(nfs): nfs:  =

>>>>>>> mount
>>>>>>> failure 1.2.3.4:/areas/testdown on /misc/areas/testdown
>>>>>>> Aug 24 09:27:00 KSTATION automount[20803]: ioctl_send_fail:  =

>>>>>>> token
>>>>>>> =3D 91
>>>>>>> Aug 24 09:27:00 KSTATION automount[20803]: failed to mount / =

>>>>>>> misc/
>>>>>>> areas/testdown
>>>>>>> -----------------------------------------
>>>>>
>>>>> Having a look at this I suspect the reason it doesn't work as
>>>>> expected
>>>>> is the waitpid(2) we do after sending the TERM signal to the mount
>>>>> process (which we have to do) is not returning. This is likely
>>>>> because
>>>>> the mount process isn't giving up in a shorter time as it used to.
>>>>
>>>> You're thinking maybe mount(2) should be as interruptible as the
>>>> socket calls that the mount command used to do?  That might be
>>>> reasonable, and I can take a look at that.
>>>
>>> In recent kernels, all those RPC calls should be using TASK_KILLABLE
>>> sleep states. SIGTERM should cause them to abort, provided that some
>>> process isn't blocking it.
>>>
>>> Perhaps TASK_KILLABLE could be backported to RHEL-5?
>>
>> That's pretty extensive, with hooks in the page cache.  I doubt RH
>> would go for that.
>
> You don't have to add the hooks in the page cache in order to make  =

> mount
> interruptible. You just need to replace the sigmask-manipulation in
> net/sunrpc and fs/nfs (a.k.a. rpc_clnt_sigmask()/rpc_clnt_sigunmask())
> with TASK_KILLABLE.

That sounds like a schlep.

> Alternatively, it might suffice to just turn on the 'intr' flag
> temporarily while doing the mount path walk, and then switch it to
> whatever default the user actually specified afterwards.

That sounds easy, especially for an EL5 kernel.  Maybe "soft" too for  =

the first few requests?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
