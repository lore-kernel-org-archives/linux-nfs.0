From: Rob Gardner <rob.gardner@hp.com>
Subject: Re: [NFS] Please help with NFS on Kubuntu Karmic 9.10
Date: Mon, 07 Dec 2009 08:54:40 -0700
Message-ID: <4B1D2540.2090500@hp.com>
References: <4B1A9F49.4000606@mindspring.com> <4B1AC4E2.10302@hp.com>
	<4B1ADDEF.1030907@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
To: Larry Alkoff <labradley@mindspring.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:48146 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751553AbZLGPz0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2009 10:55:26 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1NHfvv-0007I3-10
	for linux-nfs@vger.kernel.org; Tue, 08 Dec 2009 02:55:31 +1100
In-Reply-To: <4B1ADDEF.1030907@mindspring.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Larry Alkoff wrote:
> Rob Gardner wrote:
>   
>> Larry Alkoff wrote:
>>     
>>> I am unable to connect with Kubuntu netbook remix Karmic 9.10.
>>>
>>> I have seen many posts and articles on this issue.
>>>
>>> The problem seems to be centered around the nfs version being used
>>> and I have placed the following 2 lines in /etc/fstab:
>>>
>>> kata:/          /mnt/kata       nfs     defaults,noauto,nfsver=2  0 0
>>> kata:/home      /mnt/kata/home  nfs     defaults,noauto,nfsver=2  0 0
>>> kata is the netbook server which I am trying to mount on the client
>>> called arriba which runs on Kubuntu 8.04 LSB.
>>>
>>> Most of the posts I have read say to add 'nfsver-2' to the fstab lines.
>>> However on both client and server, cat /proc/filesystems |grep nfs
>>> shows only:
>>> nodev nfs
>>> nodev nfs4 and
>>> nodev nfsd.
>>>
>>> It seems that this problem appears when people upgrade to (K)ubuntu 9.10
>>> from an earlier version.  In my case, this is a new netbook and I loaded 
>>> the most recent version Kubuntu 9.10.  Efforts to load Kubuntu 8.04 LTS
>>> which I use on my other machines failed - possibly because of the 
>>> limited facilities on this small HP 110 Netbook.
>>>
>>> This result happens on both server kata and client arriba.
>>> I don't know that the 'nodev' means.
>>>
>>> I would like to add either nfs2 or nfs3 but have no idea how to specify
>>> this in apt-get or aptitude.
>>>
>>> I'd also like to add that I have used Linux desktops and nfs for years 
>>> (mostly on the command line) and believe it's setup correctly.
>>>
>>> Please I am requesting troubleshooting advice.
>>> It's getting really old to have to use a thumb drive to transfer files.
>>>
>>> Larryalk
>>>
>>>
>>>   
>>>       
>> Just pointing out that you do not actually state what the problem is 
>> beyond "unable to connect". It might help if you described the symptoms 
>> a little further, ie, "I see mount error -13 on the console". For what 
>> it's worth, I think the "nodev" thing is a red herring; I see the same 
>> thing on my ubuntu server, and I can mount its exported filesystems just 
>> fine.
>>
>>
>> Rob Gardner
>>
>>
>>     
>
> Hi Bob.
>   

It's Rob.

> Here is what I have found so far.
>
> I was able to mount kata / and /home about 1/2 hour ago.
> I used the mount to make a comparison between 2 files on kata.
>
> However, the next thing I tried to do (an ls I think)
> the connection hung up.  Every time I attempt to cd to the mount,
> konsole locks up and I have to quit the session.
>
> In /var/log/syslog and messages I have repeated instances of:
>
> Dec  5 15:58:50 arriba kernel: [164159.298317] nfs: server kata not 
> responding, still trying
>
> In /var/log/kern.log repeated instances of:
> Dec  5 15:58:50 arriba kernel: [164159.298317] nfs: server kata not 
> responding, still trying
>
> I have a feeling that I have told nfs to use nfsver=2 and I don't 
> actually have nfsver=2.  However, I don't know how to find out
> what I do have except for what /proc/filesystems tells me.
> And I don't know how to load another version of the nfs system.
>
> I've read a _lot_ of posts of Karmic users complaining that nfs won't 
> run.  Some have said it won't run unless you add nfsver=2 to the fstab 
> line but it's not working for me.  One person posted that he was able to
> change to nfsver=4 and I might try that since it's listed in 
> /proc/filesystems but I thing nfs4 needs kerberos to run properly.
> I have zero experience with that.
>
> It's kind of a big mess and I'm amazed that the Ubuntu people have not 
> jumped on this since nfs is so crucial but I haven't heard a word.
>
> I thought it would be a good idea to load Karmic on this netbook which 
> would prepare me for all the UI changes that have been made until the 
> LTS version coming in April but apparently not such a good decision.
> I have a big meeting Monday with the tax accountant and I don't dare to 
> try and load something else coz I'll need the netbook.  I'll probably 
> just go to the meeting and turn over any files he wants on a thumb drive.
>
> Here are a couple of urls on the problem:
>
> http://ubuntuforums.org/showthread.php?p=8398721#post8398721
> 	Man claims to have a working nfs but I don't understand what he's doing.
> https://help.ubuntu.com/community/NFSv4Howto
> 	Changing to nfs4 seems very complicated
> http://ubuntuforums.org/showthread.php?t=1308241
> 	Many peoples experiences on mounting nfs in nfs3
> 	which isn't even on my list.
>
>
> Thanks for trying to help,
> Larryalk
>
>   


It's still not too clear what the problem is from those urls. Only the 
last one actually describes any problems, and some of them are mount 
problems. It sounds like your trouble can be boiled down to "nfs works 
for a while, then doesn't." The one situation in the last url that 
sounded like that turned out to be the server's ip address changing. 
Have you confirmed that this isn't happening in your situation?

Personally, I'm skeptical about the nfsver=2 suggestion. Versions 2 and 
3 are in the same linux kernel module, so it would take some specific 
effort on the server to make nfsv3 fail while nfsv2 works ok.

Here's what I'd recommend to troubleshoot this further. First, when the 
connection "hangs", make sure the server's ip address is still valid. 
Can you ping the server? How about "rpcinfo -p"? It should show the 
usual services, ie, portmapper, nfs, mountd, etc. Could there be another 
server with the same ip address on the network? Or could it just be a 
generic network issue, ie, bad switch port? If all that looks ok, could 
it be a loss of access to the filesystem on the server? Log in to the 
server and check that the exported file systems are accessible. You can 
also enable debug output from nfs. On the client "echo 65535 
 >/proc/sys/sunrpc/nfs_debug" and on the server "echo 65535 
 >/proc/sys/sunrpc/nfsd_debug". Then try the connection again and look 
for debug messages on the console or in /var/log/messages. There might 
be a hint about what the problem is. Post anything you feel is 
"interesting".

Rob Gardner


------------------------------------------------------------------------------
Join us December 9, 2009 for the Red Hat Virtual Experience,
a free event focused on virtualization and cloud computing. 
Attend in-depth sessions from your desk. Your couch. Anywhere.
http://p.sf.net/sfu/redhat-sfdev2dev
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

