Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og112.obsmtp.com ([64.18.0.24]:47514 "HELO
	exprod5og112.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755871Ab0JSGkS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Oct 2010 02:40:18 -0400
Message-ID: <4CBD3D4E.5080305@panasas.com>
Date: Tue, 19 Oct 2010 08:40:14 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>,
        =?UTF-8?B?Q2zDoXVkaW8gTWFydGlucw==?= <ctpm@ist.utl.pt>,
        Ian Munsie <imunsie@au1.ibm.com>,
        Trond Myklebust <trond.myklebust@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Scott Romanowski <romansc@us.ibm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: NFS sillyrename side effect
References: <1287362142-sup-777@au1.ibm.com> <20101018101059.574b715a@corrin.poochiereds.net> <20101018154811.768baeb5.ctpm@ist.utl.pt> <20101018155344.6e50dbb9.ctpm@ist.utl.pt> <20101018110138.5f5001eb@corrin.poochiereds.net> <20101018171015.GB3744@fieldses.org>
In-Reply-To: <20101018171015.GB3744@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-10-18 19:10, J. Bruce Fields wrote:
> On Mon, Oct 18, 2010 at 11:01:38AM -0400, Jeff Layton wrote:
>> On Mon, 18 Oct 2010 15:53:44 +0100
>> Cláudio Martins <ctpm@ist.utl.pt> wrote:
>>
>>>
>>> On Mon, 18 Oct 2010 15:48:11 +0100 Cláudio Martins <ctpm@ist.utl.pt> wrote:
>>>>
>>>>  Section D2 ends with:
>>>>
>>>> "The NFS version 4 protocol is stateful, and could actually support
>>>> delete-on-last-close. Unfortunately there isn't an easy way to do this
>>>> and remain backwards-compatible with version 2 and 3 accessors."
>>>>
>>>>  So, theoretically, could one modify the code to selectively disable
>>>> silly rename on a client, when it knows it is talking v4 with the
>>>> server?
>>>>
>>>
>>>  BTW, to clarify, I'm assuming a scenario where the server is
>>> configured to talk v4 only, which I suspect should be common, at least
>>> when you're relying on v4 kerberos security.
>>>
>>
>> Sadly, no...
>>
>> The server does generally hold the file open as long as the client has
>> the file open. So, you could delete the file while nfsd has it open and
>> everything would probably still work.
>>
>> Suppose though that the server crashes and reboots. When it comes back
>> up, fsck figures out that the file has been unlinked and frees the
>> blocks on the disk. Now you can't reclaim the state on the open file.
>>
>> We're pretty much stuck with silly-renaming even for v4.
> 
> The server could do something like rename the file into a special
> directory somewhere 

The clients can do something similar too, like sillyrenaming the
files onto <mountpoint>/.unlinked_while_opened.<client-id>
Removing this directory when it empties.

Benny

> that only it had access to, preserving the file
> across reboot.  Then at the end of the grace period it would remove any
> files in that directory that had not been reclaimed by some client.
> 
> The problem would still remain that the *client* wouldn't know that the
> server was capable of doing this, so would still be stuck doing
> sillyrename on its own just to be sure.
> 
> NFSv4.1 adds an open return flag which allows the server to tell the
> client that the client doesn't need to do sillyrename; see the
> discussion of OPEN4_RESULT_PRESERVE_UNLINKED flag in rfc 5661.
> 
> I don't think anyone's looked into implementing that yet; might be a fun
> project.
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
