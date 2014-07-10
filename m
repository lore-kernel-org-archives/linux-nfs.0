Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:56942 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751051AbaGJOXa convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jul 2014 10:23:30 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Trond Myklebust'" <trond.myklebust@primarydata.com>
Cc: "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>,
        "'Linux Kernel mailing list'" <linux-kernel@vger.kernel.org>
References: <1404942892-18323-1-git-send-email-ffilzlnx@mindspring.com>	<CAHQdGtSUwScEdUeKT1w+-ynqNz-e1=YvDBtdu_k=_6yndFZSVQ@mail.gmail.com>	<033801cf9bc7$0d7ee190$287ca4b0$@mindspring.com>	<CAHQdGtQjCYV2jE7FGu-J+02xp25uaUUVv8uzcs5sfbKXBbVk6A@mail.gmail.com>	<CAHQdGtTkTh4MQJk6bec46OjsyZHnEGGws3b_2HA+kszzOHM-pw@mail.gmail.com>	<037801cf9bf7$1c039d20$540ad760$@mindspring.com>	<CAHQdGtSmEO8pyw+1FMmQcRgHwRufedzLRwonksueWcFSf4cm8A@mail.gmail.com>	<037d01cf9bfe$e411e450$ac35acf0$@mindspring.com> <CAHQdGtRk+MLLV=v5oyzqvhUYhrv9sV+AW9Fh0QY8vK=5EKriPA@mail.gmail.com>
In-Reply-To: <CAHQdGtRk+MLLV=v5oyzqvhUYhrv9sV+AW9Fh0QY8vK=5EKriPA@mail.gmail.com>
Subject: RE: [PATCH 1/1] Fix permission checking by NFS client for open-create with mode 000
Date: Thu, 10 Jul 2014 07:23:26 -0700
Message-ID: <03b501cf9c4a$84b12ab0$8e138010$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> >> >> Oops. Sorry, the correct sub-sub-sub-sub-....paragraph is this one:
> >> >>
> >> >>          Permission to execute a file.
> >> >>
> >> >>          Servers SHOULD allow a user the ability to read the data of the
> >> >>          file when only the ACE4_EXECUTE access mask bit is allowed.
> >> >>          This is because there is no way to execute a file without
> >> >>          reading the contents.  Though a server may treat ACE4_EXECUTE
> >> >>          and ACE4_READ_DATA bits identically when deciding to permit a
> >> >>          READ operation, it SHOULD still allow the two bits to be set
> >> >>          independently in ACLs, and MUST distinguish between them
> when
> >> >>          replying to ACCESS operations.  In particular, servers SHOULD
> >> >>          NOT silently turn on one of the two bits when the other is set,
> >> >>          as that would make it impossible for the client to correctly
> >> >>          enforce the distinction between read and execute permissions.
> >> >>
> >> >>
> >> >> > To me that translates as saying that the server SHOULD accept an
> >> >> > OPEN(SHARE_ACCESS_READ|SHARE_ACCESS_WRITE) request in the
> >> above
> >> >> > situation.
> >> >>
> >> >> Same conclusion, though....
> >> >
> >> > When I read that paragraph, my interpretation is that OPEN (and
> >> > READ)
> >> should be permission checked normally, however, if ONLY execute
> >> permission is granted, and the OPEN is read only (and READ of course
> >> is read
> >> only) then permission would be granted for the purpose of execution.
> >> But if any other combination of bits was allowed, then the paragraph
> >> doesn't apply. Thus an OPEN SHARE_ACCESS_READ |
> SHARE_ACCESS_WRITE
> >> must fail since write access was not granted (if it was, the
> >> exception doesn't apply to my reading).
> >> >
> >>
> >> Where does that paragraph say anything about SHARE_WRITE, or even
> >> mention the word "only"?
> >>
> >> All it says is that as far as the OPEN and READ operations are
> >> concerned, ACE4_EXECUTE == ACE4_READ_DATA, whereas for the
> ACCESS
> >> operation, they differ.
> >
> > I'm reading the "only" in the first sentence:
> >
> > "Servers SHOULD allow a user the ability to read the data of the file when
> only the ACE4_EXECUTE access mask bit is allowed."
> 
> How does that support your assertion that setting a SHARE_BOTH mode
> turns off the exception? There is no mention of share modes there. All it says
> is that you should grant read permissions when the execute bit is set in the
> ACL.
> 
> 
> > But to entertain the idea that I'm reading too much into that sentence, let's
> go back to the situation:
> >
> > File does not already exist
> > Application on client makes an open("/nfs4mnt/foo", O_CREAT | O_RDWR,
> > 0) system call
> >
> > What can we do between the server and client to assure success of that
> call. It works on local filesystems. It works over NFS v3. But it fails, at least
> with the Linux NFS v4 client.
> >
> > With the Linux NFS v4 client, the following does succeed (because actual
> read access was granted):
> >
> > open("/nfs4mnt/foo", O_CREAT | O_RDWR, 0400)
> >
> > And the client can write to the file.
> >
> > On the other hand, going back to my interpretation of the sentence, that is
> indeed the interpretation the Linux knfsd server is taking, because my little
> test case works as I expect it with the changes I proposed, in that and
> open("/nfs4mnt/foo", O_RDWR) fails even if the file has -wx------
> permissions (and looking at wireshark traces, I see that indeed the OPEN fails
> if read permission is not granted, but execute permission is granted and
> write access was requested.
> >
> > Ok, here is the relevant code from fs/nfsd/vfs.c:
> >
> >         /* Allow read access to binaries even when mode 111 */
> >         if (err == -EACCES && S_ISREG(inode->i_mode) &&
> >              (acc == (NFSD_MAY_READ | NFSD_MAY_OWNER_OVERRIDE) ||
> >               acc == (NFSD_MAY_READ | NFSD_MAY_READ_IF_EXEC)))
> >                 err = inode_permission(inode, MAY_EXEC);
> >
> > So if the caller had requested write access, it does not check for
> MAY_EXEC.
> 
> That's example code from one server implementation. It's not from
> authoritative source.
> 
> 
> Frank, the bottom line is that I'm not going to accept that patch as it stands,
> because it is wrong.
> The right fix here seems rather to be to put in an exception if the
> data->file_created flag is set. I'll write a patch.

Hmm, had not considered that, but that will be a solution. That should also then pass the open("foo", O_CREAT | O_RDONLY, 0) case which certainly is better.

I'll be happy to test your patch.

Ok, switching hats to server...

If I am misinterpreting that paragraph, then I'm wondering what permission check the server should be doing. As far as I can tell, both Ganesha and knfsd are doing a permission check that matches my interpretation of the paragraph. If that's wrong, I'm happy to change the Ganesha implementation.

Frank

