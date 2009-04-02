From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH v2 06/47] nfsd41: Add Kconfig symbols for NFSv4.1
Date: Thu, 02 Apr 2009 22:05:53 +0300
Message-ID: <49D50C91.7060707@panasas.com>
References: <20090402142256.GF24124@fieldses.org> <1238682355.6191.6.camel@heimdal.trondhjem.org> <20090402143141.GG24124@fieldses.org> <49D4E915.40705@panasas.com> <20090402165427.GA32533@fieldses.org> <49D4F9BE.3010102@panasas.com> <49D4FB68.20502@panasas.com> <20090402175517.GA5560@fieldses.org> <20090402175806.GB5560@fieldses.org> <49D506DD.8040705@panasas.com> <20090402184629.GF5560@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Steve Dickson <steved@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:18379 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755542AbZDBTGA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 15:06:00 -0400
In-Reply-To: <20090402184629.GF5560@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 02, 2009, 21:46 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Thu, Apr 02, 2009 at 09:41:33PM +0300, Benny Halevy wrote:
>> On Apr. 02, 2009, 20:58 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>> On Thu, Apr 02, 2009 at 01:55:17PM -0400, bfields wrote:
>>>> On Thu, Apr 02, 2009 at 08:52:40PM +0300, Benny Halevy wrote:
>>>>> On Apr. 02, 2009, 20:45 +0300, Benny Halevy <bhalevy@panasas.com> wrote:
>>>>>> On Apr. 02, 2009, 19:54 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>>>>>> On Thu, Apr 02, 2009 at 07:34:29PM +0300, Benny Halevy wrote:
>>>>>>>> On Apr. 02, 2009, 17:31 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>>>>>>>> On Thu, Apr 02, 2009 at 10:25:55AM -0400, Trond Myklebust wrote:
>>>>>>>>>> On Thu, 2009-04-02 at 10:22 -0400, J. Bruce Fields wrote:
>>>>>>>>>>> On Thu, Apr 02, 2009 at 10:16:40AM -0400, Trond Myklebust wrote:
>>>>>>>>>>>> On Thu, 2009-04-02 at 16:46 +0300, Benny Halevy wrote:
>>>>>>>>>>>>> Trond, please speak up if you want to remove CONFIG_NFS_V4_1 as well.
>>>>>>>>>>>>> On the client side minorversion 1 will be used only if the user
>>>>>>>>>>>>> explicitly asked for it with mount -o minorversion=1.
>>>>>>>>>>>> I'd feel more comfortable with being able to compile it out until the
>>>>>>>>>>>> stability of the code has been established. I'd certainly want to be
>>>>>>>>>>>> able to do that on the server side, since it has no other means to
>>>>>>>>>>>> restrict the protocol version should it turn out that NFSv4.1 has some
>>>>>>>>>>>> fatal condition.
>>>>>>>>>>> I think it's acceptable given an interface that allows choosing the
>>>>>>>>>>> supported minorversion at runtime (and that defaults 4.1 to off).
>>>>>>>>>> Is there such an interface on the server?
>>>>>>>>> That's the patch Benny just posted.  It seems like a pretty simple
>>>>>>>>> extension of the existing version-choosing interface
>>>>>>>>> (/proc/fs/nfsd/versions), though I think the version he posted defaults
>>>>>>>>> 4.1 to on?  I need to take another look.
>>>>>>>> That's right.  This can be changed trivially,
>>>>>>>> but I'll have to find and work the reason why the settings reset on
>>>>>>>> service nfs restart, otherwise it will reset itself.
>>>>>>> Maybe you're starting and stopping the server using distro init scripts
>>>>>>> that load and unload the nfsd module?
>>>>>> I'm using redhat's /etc/init.d/nfs
>>>>>> My impression was that it doesn't unload the nfsd module when the service
>>>>>> is stopped.  However it does run modprobe on "start".  I wonder if that's
>>>>>> causing the module to reload.
>>>>> Hmm, after "stop" nfsd is up and must stay up to keep serving
>>>>> /proc/fs/nfsd/versions.
>>>>>
>>>>> Giving modprobe the --first-time option reports:
>>>>> FATAL: Module nfsd already in kernel.
>>>> Yeah, actually, /proc/fs/nfsd/versions is probably getting written
>>>> somewhere in there.  That may be the effect of the --no-nfs-version
>>>> mountd argument.
>>> Whoops, sorry, rpc.nfsd: it should be the --no-nfs-version argument to
>>> rpc.nfsd.  See nfssvc_versbits() in nfs-utils/support/nfs/nfssvc.c.
>> OK. I see that now.
>> It looks like rpc.nfsd's command line syntax is all negative.
>> I.e. all versions are on by default and they can be turned off
>> using the -N option.  I can either add an option to enable minorversion
>> or have it enabled by default and add an option to disable it.
> 
> I'm not a big fan of that commandline syntax--seems to me it should give
> a range rather than a list of versions not to support.
> 
> For now the important thing is that the kernel default minorversion 1 to
> off.  We can worry about what rpc.nfsd should do later--I guess a
> commandline option to turn on specific minor versions would work....
> Maybe allow --nfs-version as well as --no-nfs-version?

Sounds like a good idea.
How about --nfs-versions (in plural) to correspond to /proc/fs/nfsd/versions
and then pass the whole versions string?

Benny

> 
> --b.
