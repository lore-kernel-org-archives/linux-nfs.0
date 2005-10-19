From: "Luis P Caamano" <lpc@racemi.com>
Subject: Re: Autofs-mounted NFS directories disappearing
Date: Wed, 19 Oct 2005 09:02:55 -0400 (EDT)
Message-ID: <1210.24.99.177.201.1129726975.squirrel@24.99.177.201>
References: <20051019033529.DE4E912E7A@sc8-sf-spam2.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: "Neil Brown" <neilb@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ESDeN-0003J0-28
	for nfs@lists.sourceforge.net; Wed, 19 Oct 2005 06:06:35 -0700
Received: from 216-91-87-190.biltmorecomm.com ([216.91.87.190] helo=racemi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ESDeK-0004wi-Kf
	for nfs@lists.sourceforge.net; Wed, 19 Oct 2005 06:06:35 -0700
In-Reply-To: <20051019033529.DE4E912E7A@sc8-sf-spam2.sourceforge.net>
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


On Tue, October 18, 2005 11:31 pm, John Medway wrote:
>
> Date: Tue, 18 Oct 2005 13:27:02 -0700
> To: Neil Brown <neilb@suse.de>
> From: "John Medway, Enuclia Semiconductor" <john.medway@enuclia.com>
> Subject: Re: [NFS] Autofs-mounted NFS directories disappearing
> Cc: "John Medway, Enuclia Semiconductor" <john.medway@enuclia.com>,
> 	nfs@lists.sourceforge.net
>
> Neil,
>
> Made this change late last week, and while it seems to have fixed the
> problem, now we're seeing a roughly daily out of memory kernel panic on
> the
> machine, which did not happen beforehand. I can't say for sure they are
> related, but they are, at least, coincidental. I'm going to revert the
> change, to see if the panics stop.
>
> I'm unfortunately semi-stuck with this kernel for the moment, so I was
> wondering if there are other ideas I could try.
>
> JM
>
>
> At 06:30 PM 10/10/2005, Neil Brown wrote:
>>On Monday October 10, john.medway@enuclia.com wrote:
>> > Intermittently, sub directories of people's home dirs go bad on some
>> of my
>> > clients and report stale NFS handles when the user tries to access t=
he
>> > directory. Sometimes when this occurs, the subdir has been accessed =
in
>> the
>> > last few minutes. Sometimes, not for days (and it's just still mount=
ed
>> > because they have a shell sitting in it).
>> >
>> > It's usually a couple of levels down, say ~foo/a/b/c and "c" will go
>> stale.
>> > If you're in it with a shell you get Stale NFS handle. If you're in
>> "b"
>> and
>> > do an ls, "c" doesn't appear. If the missing/stale dir "c" is listed
>> on
>> > another machine, or on the server, it usually immediately goes
>> un-stale on
>> > the problem box.
>> >
>> > Thoughts?
>>..
>> > Server:
>> >          Redhat 2.6.9-5.ELsmp #1 SMP
>> >                  Wed Jan 5 19:30:39 EST 2005 i686 athlon i386
>> GNU/Linux


We are also stuck with this kernel because of a special
driver that doesn't work on newer kernels.  We had to
apply the patch for the ENOENT defect to this kernel
and it's been working fine.

The patch and explanation of the problem is in RedHat's
bugzilla:

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D150759


----------------------------------
Luis P. Caamano | Racemi, Inc.
lpc@racemi.com  | Atlanta, GA, USA
----------------------------------



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
