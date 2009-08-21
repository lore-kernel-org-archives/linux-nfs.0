From: Stefan Egli <stefan.egli@gmail.com>
Subject: NFS v3 cached directory content out of sync
Date: Fri, 21 Aug 2009 20:22:12 +0200
Message-ID: <d4098e2f0908211122y5d024dd1sd2f80356749315cc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:39130 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932240AbZHUSWL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Aug 2009 14:22:11 -0400
Received: by fxm17 with SMTP id 17so601813fxm.37
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2009 11:22:12 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi there,

I'm experiencing a problem with NFS v3. After a rush of data written
to a particular NFS partition (to/from NetApp) I have noticed
directory listings between three different NFS v3 clients (doing a'ls
in the same directory) to see different content. The 'rush of data'
included approx 400GB (and took a few hours to do so). The
inconsistency that the three clients experienced was still the case 4
hours after the mentioned data rush.

I would 'somehow understand' that such a 'data storm' could maybe
overwhelm the NFS client's caches - and thus would 'accept' (although
not liking it) a delay between the client's cache updates. But that
such an inconsistency is still existing 4 hours afterwards is IMHO a
plain bug.

=A0Question 1: Would you agree that this is a bug or is it 'NFS as desi=
gned' ?

What I did having seen this is creating a new file in that directory -
and voila, all clients immediately got to see the right directory
content. This again calmed my nerves as in 'NFS still works'.

Having said that - I now did some more testing with this NFS cache
delay and noticed that file content updates between the three NFS
clients easily takes a few seconds - up to 10-15 seconds.

=A0Question 2: Is such a file content delay in NFS 'as designed' - I'm
assuming that fiddling with NFS mount parameters could put a 'defined
maximum' to such a delay? Or is there no such maximum and under 'bad
luck' situations it can go infinitely high (which would be Q1) ?

=A0Question 3: What is a suggested best-practice NFS mount parameter se=
t
for complying with the following requirements:
=A0=A0 * lots of reads - tons of files - reads often from different fil=
es
=A0=A0 * few writes - but if written it should propagate to all NFS
clients 'immediately'
=A0=A0 * high load situations (as with the 400GB read/write stuff above=
) -
and after or even during this doing a 'ls' in a directory should
produce consistent results on different attached NFS clients

=A0Question 4: If we'd somehow manually detected such a directory
content inconsistency - would there be something like a 'hey NFS
client, flush all NFS caches NOW' thing?

=A0Question 5: any of this related to commit 37d9d76d8b3a2ac5817e1fa326=
3cfe
0fdb439e51: NFS: flush cached directory information slightly more readi=
ly. ?

Thanks for answers to any or all of above! :)

MUCH appreciated!

Regards,
Stefan
