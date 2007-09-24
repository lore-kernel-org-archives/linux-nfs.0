From: David Liontooth <liontooth@cogweb.net>
Subject: Re: Bug#443591: nfs-kernel-server: Unexporting directories
 no	longer working
Date: Mon, 24 Sep 2007 16:29:02 -0700
Message-ID: <46F8483E.3000103@cogweb.net>
References: <20070922174231.11200.29119.reportbug@localhost.localdomain>	<20070923000102.GA29785@uio.no>
	<18167.24613.796605.199161@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: 443591@bugs.debian.org, nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZxMX-0008KH-IU
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 16:29:14 -0700
Received: from smtp-2.smtp.ucla.edu ([169.232.47.136])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZxMb-0003Wj-Cb
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 16:29:18 -0700
In-Reply-To: <18167.24613.796605.199161@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Hi Neil,

Thanks for looking.

Neil Brown wrote:
> On Sunday September 23, sgunderson@bigfoot.com wrote:
>   
>> On Sat, Sep 22, 2007 at 10:42:31AM -0700, David Liontooth wrote:
>>     
>>> Package: nfs-kernel-server
>>> Version: 1:1.1.0-13
>>> Severity: normal
>>>
>>>
>>> The command to unexport a directory appears to no longer have any effect.
>>>
>>> I issue "exportfs -u :/tv01" and "exportfs" shows /tv01 still exported; consequently, I cannot unmount it.
>>> In contrast, removing /tv01 from /etc/exports and then running exportfs -ra successfully removes the export.
>>>
>>> This used to work fine.
>>>       
>> Sending this on to upstream, as I cannot see any good reason offhand why it
>> should not work.
>>     
>
> Some simple testing and code review suggests that this works as
> expected.  However it is possible that I am expecting something
> different to you, or testing something different.
>
> You say you:
>     exportfs -u :/tv01
>
> What exactly is in your /etc/exports that this is expected to revert?
>   

/tv01 \
        134.32.443.30(ro,no_subtree_check,async) \
        134.32.443.32(ro,no_subtree_check,async) \
        134.32.443.33(ro,no_subtree_check,async) \
        134.32.443.34(ro,no_subtree_check,async) \
        134.32.443.35(ro,no_subtree_check,async) \
        134.32.443.36(ro,no_subtree_check,async) \
        134.32.443.37(ro,no_subtree_check,async)

Several other drives have similar entries.
> The obvious answer would be
>
>     /tv01  (some,flags,here)
>
> however "exportfs" will complain about that, so I suspect not.
>
> Maybe you have:
>
>     /tv01 somehost(someflags)  otherhost(otherflags)
>
> and you expect
>     exportfs -u :/tv01
>
> to unexport /tv01 to all hosts?  I would agree that doesn't work.  Did
> it ever?  What version?
>   

I see. So that would unexport only the first one?

Can I unexport only /tv01 to all hosts?
(If it's just a matter of my being uninformed, let's close the bug --
but I'd appreciate an answer!)

> As an aside, you can always:
>    exportfs -f
> and then unmount filesystems.  They will be free to be unmounted until
> the next NFS access request arrives.  Maybe that will serve your
> needs?
>   
I see -- that may be helpful -- but what if someone is accessing one of
the drives right then?
I would prefer to have individual control; I export a dozen other drives
to several different machines, and they should not be unexported.

Dave





-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
