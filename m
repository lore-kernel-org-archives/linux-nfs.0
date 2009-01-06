From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 6 Jan 2009 18:51:55 -0500
Message-ID: <8BC8AF03-457C-4B26-9500-955F91A8A60E@oracle.com>
References: <20090106011314.534653345@us.ibm.com> <20090106011314.961946803@us.ibm.com> <20090106200229.GA17031@us.ibm.com> <1231274682.20316.65.camel@heimdal.trondhjem.org> <20090106215831.GE18147@us.ibm.com> <m1eizg11fy.fsf@frodo.ebiederm.org> <1231283734.8041.6.camel@heimdal.trondhjem.org> <20090106233238.GD13785@fieldses.org> <1231284943.8041.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Linux Containers <containers@lists.linux-foundation.org>,
	linux-nfs@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:30417 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbZAFXwY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2009 18:52:24 -0500
In-Reply-To: <1231284943.8041.8.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 6, 2009, at Jan 6, 2009, 6:35 PM, Trond Myklebust wrote:
> On Tue, 2009-01-06 at 18:32 -0500, J. Bruce Fields wrote:
>> On Tue, Jan 06, 2009 at 06:15:34PM -0500, Trond Myklebust wrote:
>>> On Tue, 2009-01-06 at 15:04 -0800, Eric W. Biederman wrote:
>>>> That implies to me you want to capture the value at mount time,  
>>>> and to
>>>> pass it in to the rpc_call creation, and only at very specific well
>>>> defined points where we interact with user space should we examine
>>>> current->utsname().  At which point there should be no question
>>>> of current->utsname() is valid as the user space process is alive.
>>>
>>> Why pretend that the filesystem is owned by a particular  
>>> namespace? It
>>> can, and will be shared among many containers...
>>
>> If the only purpose of this is to fill in the auth_unix cred then
>> shouldn't it be part of whatever cred structures are passed around?
>
> So how does tracking it in a shared structure like the rpc_client  
> help?
> If you consider it to be part of the cred, then it needs to be tracked
> in the cred...

I think generating a proper AUTH_SYS cred, given the existence of  
containers, is the essential question here.

However, we use nodename for lock owners too... perhaps that deserves  
a separate solution.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
