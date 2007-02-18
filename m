From: devzero@web.de
Subject: Re: Annoying exports problem
Date: Sun, 18 Feb 2007 17:12:43 +0100
Message-ID: <1634529243@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
To: NFS@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

hi !

>> But maybe the key issue is not so much how it is "meant to work", but
>> how we "want it to work".
>> I suspect it would be very valuable and no harm to allow
>> =

>>    /storage       *(rw,no_root_squash,async,crossmnt)
>> =

>> to export everything below /storage, including other filesystems.
>
>That's exactly what I was looking for.  I see a bunch of references to
>crossmnt basically saying it was never implemented.  Maybe still the case?

here`s some loud "i`d like that , too !!!", since i lost the ability to com=
fortably export loopback mounted filesystems (.iso) when switching from one=
 distro to a later release, where userspace nfsd was replace by knfsd. my c=
urrent workaround is using unfs3, but that`s a) slow and b) not being bundl=
ed with major distros, so integration of unfs3 is conflicting with bundled =
knfsd and always a pain to setup.

i have solved that "no more than 256 loopback devices available for loopbac=
k mounts"-problem for my huge cd-rom server, by now the only remaining issu=
e to fix is "export every loopback mount below /cd-roms by a single nfs-sha=
re", which shouldn`t be too exotic desire !? :)

regards
roland






On 5/17/06 4:33 PM, "Neil Brown" <neilb@suse.de> wrote:

> On Wednesday May 17, bfields@fieldses.org wrote:
>> On Wed, May 17, 2006 at 04:39:04PM +1000, Neil Brown wrote:
>>> On Tuesday May 16, jeremy@smokehabanos.com wrote:
>>>> I actually got it to work in the little time since my initial post.  T=
he
>>>> only way I could do it was to export both the root filesystem and the
>>>> individual directories within the /storage.  So it looks like this:
>>>> =

>>>> /storage       *(rw,no_root_squash,async)
>>>> /storage/space0       *(rw,no_root_squash,async,no_subtree_check,nohid=
e)
>>>> /storage/space1       *(rw,no_root_squash,async,no_subtree_check,nohid=
e)
>>>> /storage/space2       *(rw,no_root_squash,async,no_subtree_check,nohid=
e)
>>>> /storage/space3       *(rw,no_root_squash,async,no_subtree_check,nohid=
e)
>>>> /storage/space4       *(rw,no_root_squash,async,no_subtree_check,nohid=
e)
>>>> /storage/space5       *(rw,no_root_squash,async,no_subtree_check,nohid=
e)
>>> =

>>> This works too
>>> Putting 'crossmnt' on the first line should remove the need for the
>>> remaining lines.
>> =

>> It should remove the need for the nohide option on those lines, but I
>> think the export lines will still be required.  Is that not how it's
>> meant to work?
> =

> Not sure... it is a while since I have looked at that code.
> =

> But maybe the key issue is not so much how it is "meant to work", but
> how we "want it to work".
> I suspect it would be very valuable and no harm to allow
> =

>    /storage       *(rw,no_root_squash,async,crossmnt)
> =

> to export everything below /storage, including other filesystems.

That's exactly what I was looking for.  I see a bunch of references to
crossmnt basically saying it was never implemented.  Maybe still the case?

Thanks
-jeremy

> =

> I've put it on my todo list to look into one day.
> =

> NeilBrown
_______________________________________________________________________
Viren-Scan f=FCr Ihren PC! Jetzt f=FCr jeden. Sofort, online und kostenlos.
Gleich testen! http://www.pc-sicherheit.web.de/freescan/?mc=3D022222


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
