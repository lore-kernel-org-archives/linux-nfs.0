From: James Bardin <jbardin@bu.edu>
Subject: Re: nfs sec=krb5 on RHEL and CentOS
Date: Thu, 25 Jan 2007 18:40:55 -0500
Message-ID: <45B94007.60609@bu.edu>
References: <a3b675320701211411r45d010f8jd7132deedcf68804@mail.gmail.com>	
	<45B73D93.1020508@RedHat.com> <45B7C85C.80105@bu.edu>	
	<20070124233908.GS6587@fieldses.org>	
	<a3b675320701241614p360a596fjb92723eb5ce6dfd9@mail.gmail.com>	
	<45B9084F.7090307@bu.edu> <45B92779.3000202@bu.edu>
	<4d569c330701251514p3bde8ec9uaf5d07084e94888e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HAEDE-00026i-VL
	for nfs@lists.sourceforge.net; Thu, 25 Jan 2007 15:41:02 -0800
Received: from wx-out-0506.google.com ([66.249.82.230])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HAEDE-0001xE-4j
	for nfs@lists.sourceforge.net; Thu, 25 Jan 2007 15:41:02 -0800
Received: by wx-out-0506.google.com with SMTP id i30so1081140wxd
	for <nfs@lists.sourceforge.net>; Thu, 25 Jan 2007 15:40:59 -0800 (PST)
In-Reply-To: <4d569c330701251514p3bde8ec9uaf5d07084e94888e@mail.gmail.com>
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



Kevin Coffman wrote:
> On 1/25/07, James Bardin <jbardin@bu.edu> wrote:
>>
>> > I'm almost there!
>> > Between the nfs-utils patch, and the noacl option, I have my 32bit
>> > systems working. (thanks Steve)
>> >
>> > On x86_64, I'm having kerberos problems (exact same config):
>> >
>> > rpc.gssd[4871]: handling krb5 upcall
>> > rpc.gssd[4871]: getting credentials for client with uid xxxx for
>> > server yyyy.bu.edu
>> > rpc.gssd[4871]: CC file 'krb5cc_xxxx_bSULEy' being considered
>> > rpc.gssd[4871]: CC file 'krb5cc_xxxx_bSULEy' matches name check and
>> > has mtime of 1169750861
>> > rpc.gssd[4871]: using FILE:/tmp/krb5cc_xxxx_bSULEy as credentials
>> > cache for client with uid xxxx for server yyyy.bu.edu
>> > rpc.gssd[4871]: creating context using euid xxxx (save_uid 0)
>> > rpc.gssd[4871]: creating tcp client for server yyyy.bu.edu
>> > rpc.gssd[4871]: WARNING: can't create rpc_clnt for server
>> > engna1.bu.edu for user with uid xxxx: RPC: Success rpc.gssd[4871]:
>> > WARNING: Failed to create krb5 context for user with uid xxxx for
>> > server yyyy.bu.edu
>> > rpc.gssd[4871]: doing error downcall
>> >
>> >
>> x86_64 is working on an older version, I read the errata, and it
>> shouldn't effect us, but something is wrong in the new ones. This is
>> with sec=krb5.
>> nfs-utils-1.0.6-77 causes the above problems
>> nfs-utils-1.0.6-70 will hang on rpc.gssd
>> nfs-utils-1.0.6-65 is working.
>>
>>
>>
>> > Kevin Coffman wrote:
>> > Unless Steve has pulled in more fixes than I think, you'll probably
>> > need to upgrade libgssapi and maybe nfs-utils to get 64-bit working.
>> > I was going to look at what is in nfs-utils-1.0.6-77, but my RHEL 4
>> > subscription has expired :-/.  Working on that.
>> >
>> > Offhand, I don't recall exactly when those changes went in, but I'll
>> > check.
>> I'm trying to keep to the RHEL src tree as much as possible, this is
>> going on a lot of machines.
>> Do you know of a patch/update for libgssapi that I could try?
>>
>> thanks
>> -jim
>
> OK, sorry for the false alarm.  I've looked closer at what is included
> in nfs-utils-1.0.6-70 on another RHEL system here.  From what I can
> tell, the -70 version should have the 64-bit fixes that I am aware of.
> It sounds like the -65 had them as well.
>
> It looks like Steve Dickson has been working hard!  He may be the best
> person to say what changed between nfs-utils-1.0.6-65 and -70 and -77
> versions that might be causing your problems.
>
> K.C.
>
I don't know if it's related, but sometimes when I build an nfs-utils 
src.rpm, it dumps out saying the GSS with KRB5 support not found. If I 
try to build again, it works???




-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
