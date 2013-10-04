Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:44698 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754729Ab3JDPqg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Oct 2013 11:46:36 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Fri, 04 Oct 2013 11:39:54 -0400
From: David Quigley <selinux@davequigley.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Daniel J Walsh <dwalsh@redhat.com>, Stephen Smalley <sds@tycho.nsa.gov>,
        Eric Paris <eparis@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: Hey we are seeing a big problem with Labeled NFS
In-Reply-To: <20131004152944.GE1577@fieldses.org>
References: <524EB4C2.6070804@redhat.com>
 <a72f70f2dce1409f383d634c06b17b40@countercultured.net>
 <20131004143549.GC1577@fieldses.org>
 <46df4f789cbeb203d1355adbd3a346c6@countercultured.net>
 <20131004150505.GD1577@fieldses.org>
 <7392559a27900ee1dfe69ebbe0fd468e@countercultured.net>
 <20131004152944.GE1577@fieldses.org>
Message-ID: <cc6c106aa0b1ead440ff70a2ca002f69@countercultured.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

( Adding linux-nfs to the list of people)

Here is a summary of the discussion so far.

Dan Walsh is seeing issues with Labeled NFS. The issue he is seeing is 
that a label change on the server is not reflected on the client until a 
remount of the client. There should be a delay in the label change being 
reflected in the client as we don't yet have the label change 
notification in. However it should only be until the cache for the file 
attribute is invalidated and the next getfattr call revalidates the 
label. It is unclear why a remount is needed at this time.

Bruce has expressed the concern that the label change notification was 
not designed for this particular use case and the 
protocol/implementation may need to be reworked.

My understanding of the usecases discussed for Labeled NFS have sVirt 
and NFS mounted home. Both of which will make label changes quite often. 
Part of SVirt is support in libvirt to change the category fields on the 
vm images to match that of the starting qemu process. This gives the 
process separation that just using types alone would make difficult. For 
home directories labels may change all the time from a client 
perspective if another client is modifying file labels. I think what we 
conveyed a while back (I don't remember the conversation) is that a 
whole sale relabel of the server from underneath the clients is unlikely 
to happen. However there is definitely a real use case where client A 
modifies the label on a file and Client B needs to see that. Without 
having full support where the server enforces policy we're relying on 
the client to enforce those policies which they can't reliably do 
without knowing about the label change. One thing we had discussed in 
the past though is that the cache timeout could be sufficient in the 
situation where we lack the label change notification under the 
assumption that if the file was opened with that label at least for that 
short time it should still be ok for it to still read/write to that 
file. There are situations where that is not ideal though. Its not clear 
to me why the client is requiring a remount to get the label change 
though. Upon cache invalidation another getfattr call for the label 
should be sent and it should pull it back.



On 10/04/2013 11:29, J. Bruce Fields wrote:
> On Fri, Oct 04, 2013 at 11:25:43AM -0400, David Quigley wrote:
>> 
>> 
>> On 10/04/2013 11:05, J. Bruce Fields wrote:
>> >On Fri, Oct 04, 2013 at 11:00:22AM -0400, David Quigley wrote:
>> >>I think we do have a problem then. Two of the major usecases for
>> >>LNFS were SVirt and NFS Mounted Home Directories. Both of which will
>> >>make label changes quite often. Part of SVirt is support in libvirt
>> >>to change the category fields on the vm images to match that of the
>> >>starting qemu process. This gives the process separation that just
>> >>using types alone would make difficult. For home directories that
>> >>may change all the time from a client perspective if another client
>> >>is modifying file labels. I think what we conveyed a while back (I
>> >>don't remember the conversation) is that a whole sale relabel of the
>> >>server from underneath the clients is unlikely to happen. However
>> >>there is definitely a real use case where client A modifies the
>> >>label on a file and Client B needs to see that. Without having full
>> >>support where the server enforces policy we're relying on the client
>> >>to enforce those policies which they can't reliably do without
>> >>knowing about the label change. One thing we had discussed in the
>> >>past though is that the cache timeout could be sufficient in the
>> >>situation where we lack the label change notification under the
>> >>assumption that if the file was opened with that label at least for
>> >>that short time it should still be ok for it to still read/write to
>> >>that file. There are situations where that is not ideal though. Its
>> >>not clear to me why the client is requiring a remount to get the
>> >>label change though. Upon cache invalidation another getfattr call
>> >>for the label should be sent and it should pull it back.
>> >
>> >OK.  Is there some reason this isn't cc'd to linux-nfs@vger.kernel.org?
>> >
>> >--b.
>> >
>> 
>> The only reason I can see is I think that not everyone is subscribed
>> to it but we can CC it anyway. I guess its on vger now so it should
>> allow non-subscribed people to post.
> 
> Would you mind posting a summary (may just what you wrote above) with
> all of us on the cc?
> 
> --b.
> 
>> 
>> 
>> >>
>> >>Dave
>> >>
>> >>On 10/04/2013 10:35, J. Bruce Fields wrote:
>> >>>On Fri, Oct 04, 2013 at 10:30:10AM -0400, David Quigley wrote:
>> >>>>That makes perfect sense. Right now we only have label transport
>> >>>>implemented. We haven't implemented the portion of the spec which
>> >>>>does the label change notification yet. Until that is done you'll
>> >>>>have to wait for the cached file data to time out and get repulled
>> >>>>from the server. This use to be 5 seconds. Its not clear now how
>> >>>>long it will be. Once label change notification is implemented this
>> >>>>shouldn't be as much of a problem.
>> >>>
>> >>>I don't know, you may need to unmount and remount to be absolutely
>> >>>sure.
>> >>>
>> >>>This was all designed for a use case (virtualization) where we
>> >>>understood that labels would rarely if ever be changed.
>> >>>
>> >>>If that's wrong, that's an unfortunate miscommunication, and the
>> >>>implementation and possibly the protocol may need to be fixed....
>> >>>
>> >>>--b.
>> >>>
>> >>>>
>> >>>>On 10/04/2013 08:29, Daniel J Walsh wrote:
>> >>>>>-----BEGIN PGP SIGNED MESSAGE-----
>> >>>>>Hash: SHA1
>> >>>>>
>> >>>>>Can't find the bugzilla right now, but on a Fedora 20 client and
>> >>>>>server.  When
>> >>>>>you setup a labeled NFS home dir.  After mount a change of a label
>> >>>>>on the
>> >>>>>server does not get reflected back to the client, until he does an
>> >>>>>unmount and
>> >>>>>remount. Not sure if this works if a different client changes the
>> >>>>>label.  Is
>> >>>>>this because the nfs part of the kernel never gets informed of the
>> >>>>>label change.
>> >>>>>
>> >>>>>mount remote:/nfsmount /mnt
>> >>>>>touch /mnt/dwalsh
>> >>>>>chcon -t usr_t /mnt/dwalsh
>> >>>>>
>> >>>>>On server:
>> >>>>>
>> >>>>>chcon -t etc_t /mnt/dwalsh
>> >>>>>
>> >>>>>
>> >>>>>On client dwalsh still shows usr_t.
>> >>>>>-----BEGIN PGP SIGNATURE-----
>> >>>>>Version: GnuPG v1.4.14 (GNU/Linux)
>> >>>>>Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/
>> >>>>>
>> >>>>>iEYEARECAAYFAlJOtMIACgkQrlYvE4MpobNmJwCfbzCe1wkcBRdNaNrIUlgdM/6R
>> >>>>>Lo8AoLRZdEwO252fLiBT/N09sl2uLZKK
>> >>>>>=cist
>> >>>>>-----END PGP SIGNATURE-----
>> >>>>
