Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og103.obsmtp.com ([64.18.0.145]:46050 "HELO
	exprod5og103.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753989Ab0JURuQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Oct 2010 13:50:16 -0400
Message-ID: <4CC07D54.7070204@panasas.com>
Date: Thu, 21 Oct 2010 19:50:12 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@redhat.com>,
        =?UTF-8?B?Q2zDoXVkaW8gTWFydGlucw==?= <ctpm@ist.utl.pt>,
        Ian Munsie <imunsie@au1.ibm.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Scott Romanowski <romansc@us.ibm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: NFS sillyrename side effect
References: <1287362142-sup-777@au1.ibm.com>	 <20101018101059.574b715a@corrin.poochiereds.net>	 <20101018154811.768baeb5.ctpm@ist.utl.pt>	 <20101018155344.6e50dbb9.ctpm@ist.utl.pt>	 <20101018110138.5f5001eb@corrin.poochiereds.net>	 <20101018171015.GB3744@fieldses.org>  <4CBD3D4E.5080305@panasas.com> <1287495168.2969.9.camel@heimdal.trondhjem.org>
In-Reply-To: <1287495168.2969.9.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-10-19 15:32, Trond Myklebust wrote:
> On Tue, 2010-10-19 at 08:40 +0200, Benny Halevy wrote:
>> On 2010-10-18 19:10, J. Bruce Fields wrote:
>>> On Mon, Oct 18, 2010 at 11:01:38AM -0400, Jeff Layton wrote:
>>>> On Mon, 18 Oct 2010 15:53:44 +0100
>>>> Cláudio Martins <ctpm@ist.utl.pt> wrote:
>>>>
>>>>>
>>>>> On Mon, 18 Oct 2010 15:48:11 +0100 Cláudio Martins <ctpm@ist.utl.pt> wrote:
>>>>>>
>>>>>>  Section D2 ends with:
>>>>>>
>>>>>> "The NFS version 4 protocol is stateful, and could actually support
>>>>>> delete-on-last-close. Unfortunately there isn't an easy way to do this
>>>>>> and remain backwards-compatible with version 2 and 3 accessors."
>>>>>>
>>>>>>  So, theoretically, could one modify the code to selectively disable
>>>>>> silly rename on a client, when it knows it is talking v4 with the
>>>>>> server?
>>>>>>
>>>>>
>>>>>  BTW, to clarify, I'm assuming a scenario where the server is
>>>>> configured to talk v4 only, which I suspect should be common, at least
>>>>> when you're relying on v4 kerberos security.
>>>>>
>>>>
>>>> Sadly, no...
>>>>
>>>> The server does generally hold the file open as long as the client has
>>>> the file open. So, you could delete the file while nfsd has it open and
>>>> everything would probably still work.
>>>>
>>>> Suppose though that the server crashes and reboots. When it comes back
>>>> up, fsck figures out that the file has been unlinked and frees the
>>>> blocks on the disk. Now you can't reclaim the state on the open file.
>>>>
>>>> We're pretty much stuck with silly-renaming even for v4.
>>>
>>> The server could do something like rename the file into a special
>>> directory somewhere 
>>
>> The clients can do something similar too, like sillyrenaming the
>> files onto <mountpoint>/.unlinked_while_opened.<client-id>
>> Removing this directory when it empties.
> 
> This would require access, directory create, and delete permissions for
> the directory '<mountpoint>/', which is not always a given.

Correct. But that's pretty easy to probe :)

> 
> Besides, what if the server reboots, and my clientid changes?

By <client-id> I meant a unique identifier for the client, not necessarily
the nfsv4.x clientid.  The client could just as well use its ip address
(to help admins deal with the aftermath in case the client goes away) and its
boot time, or even a random string.

Benny

> 
> Trond
