Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f175.google.com ([209.85.220.175]:33322 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263AbaGJMmU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 08:42:20 -0400
Received: by mail-vc0-f175.google.com with SMTP id hy4so10314949vcb.20
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 05:42:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <037d01cf9bfe$e411e450$ac35acf0$@mindspring.com>
References: <1404942892-18323-1-git-send-email-ffilzlnx@mindspring.com>
	<CAHQdGtSUwScEdUeKT1w+-ynqNz-e1=YvDBtdu_k=_6yndFZSVQ@mail.gmail.com>
	<033801cf9bc7$0d7ee190$287ca4b0$@mindspring.com>
	<CAHQdGtQjCYV2jE7FGu-J+02xp25uaUUVv8uzcs5sfbKXBbVk6A@mail.gmail.com>
	<CAHQdGtTkTh4MQJk6bec46OjsyZHnEGGws3b_2HA+kszzOHM-pw@mail.gmail.com>
	<037801cf9bf7$1c039d20$540ad760$@mindspring.com>
	<CAHQdGtSmEO8pyw+1FMmQcRgHwRufedzLRwonksueWcFSf4cm8A@mail.gmail.com>
	<037d01cf9bfe$e411e450$ac35acf0$@mindspring.com>
Date: Thu, 10 Jul 2014 08:42:19 -0400
Message-ID: <CAHQdGtRk+MLLV=v5oyzqvhUYhrv9sV+AW9Fh0QY8vK=5EKriPA@mail.gmail.com>
Subject: Re: [PATCH 1/1] Fix permission checking by NFS client for open-create
 with mode 000
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> >> Oops. Sorry, the correct sub-sub-sub-sub-....paragraph is this one:
>> >>
>> >>          Permission to execute a file.
>> >>
>> >>          Servers SHOULD allow a user the ability to read the data of the
>> >>          file when only the ACE4_EXECUTE access mask bit is allowed.
>> >>          This is because there is no way to execute a file without
>> >>          reading the contents.  Though a server may treat ACE4_EXECUTE
>> >>          and ACE4_READ_DATA bits identically when deciding to permit a
>> >>          READ operation, it SHOULD still allow the two bits to be set
>> >>          independently in ACLs, and MUST distinguish between them when
>> >>          replying to ACCESS operations.  In particular, servers SHOULD
>> >>          NOT silently turn on one of the two bits when the other is set,
>> >>          as that would make it impossible for the client to correctly
>> >>          enforce the distinction between read and execute permissions.
>> >>
>> >>
>> >> > To me that translates as saying that the server SHOULD accept an
>> >> > OPEN(SHARE_ACCESS_READ|SHARE_ACCESS_WRITE) request in the
>> above
>> >> > situation.
>> >>
>> >> Same conclusion, though....
>> >
>> > When I read that paragraph, my interpretation is that OPEN (and READ)
>> should be permission checked normally, however, if ONLY execute
>> permission is granted, and the OPEN is read only (and READ of course is read
>> only) then permission would be granted for the purpose of execution. But if
>> any other combination of bits was allowed, then the paragraph doesn't
>> apply. Thus an OPEN SHARE_ACCESS_READ | SHARE_ACCESS_WRITE must
>> fail since write access was not granted (if it was, the exception doesn't apply
>> to my reading).
>> >
>>
>> Where does that paragraph say anything about SHARE_WRITE, or even
>> mention the word "only"?
>>
>> All it says is that as far as the OPEN and READ operations are concerned,
>> ACE4_EXECUTE == ACE4_READ_DATA, whereas for the ACCESS operation,
>> they differ.
>
> I'm reading the "only" in the first sentence:
>
> "Servers SHOULD allow a user the ability to read the data of the file when only the ACE4_EXECUTE access mask bit is allowed."

How does that support your assertion that setting a SHARE_BOTH mode
turns off the exception? There is no mention of share modes there. All
it says is that you should grant read permissions when the execute bit
is set in the ACL.


> But to entertain the idea that I'm reading too much into that sentence, let's go back to the situation:
>
> File does not already exist
> Application on client makes an open("/nfs4mnt/foo", O_CREAT | O_RDWR, 0) system call
>
> What can we do between the server and client to assure success of that call. It works on local filesystems. It works over NFS v3. But it fails, at least with the Linux NFS v4 client.
>
> With the Linux NFS v4 client, the following does succeed (because actual read access was granted):
>
> open("/nfs4mnt/foo", O_CREAT | O_RDWR, 0400)
>
> And the client can write to the file.
>
> On the other hand, going back to my interpretation of the sentence, that is indeed the interpretation the Linux knfsd server is taking, because my little test case works as I expect it with the changes I proposed, in that and open("/nfs4mnt/foo", O_RDWR) fails even if the file has -wx------ permissions (and looking at wireshark traces, I see that indeed the OPEN fails if read permission is not granted, but execute permission is granted and write access was requested.
>
> Ok, here is the relevant code from fs/nfsd/vfs.c:
>
>         /* Allow read access to binaries even when mode 111 */
>         if (err == -EACCES && S_ISREG(inode->i_mode) &&
>              (acc == (NFSD_MAY_READ | NFSD_MAY_OWNER_OVERRIDE) ||
>               acc == (NFSD_MAY_READ | NFSD_MAY_READ_IF_EXEC)))
>                 err = inode_permission(inode, MAY_EXEC);
>
> So if the caller had requested write access, it does not check for MAY_EXEC.

That's example code from one server implementation. It's not from
authoritative source.


Frank, the bottom line is that I'm not going to accept that patch as
it stands, because it is wrong.
The right fix here seems rather to be to put in an exception if the
data->file_created flag is set. I'll write a patch.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
