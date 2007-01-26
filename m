From: James Bardin <jbardin@bu.edu>
Subject: Re: nfs sec=krb5 on RHEL and CentOS
Date: Fri, 26 Jan 2007 12:07:45 -0500
Message-ID: <45BA3561.1020902@bu.edu>
References: <a3b675320701211411r45d010f8jd7132deedcf68804@mail.gmail.com>	
	<45B73D93.1020508@RedHat.com> <45B7C85C.80105@bu.edu>	
	<20070124233908.GS6587@fieldses.org>	
	<a3b675320701241614p360a596fjb92723eb5ce6dfd9@mail.gmail.com>	
	<45B9084F.7090307@bu.edu> <45B92779.3000202@bu.edu>
	<4d569c330701251514p3bde8ec9uaf5d07084e94888e@mail.gmail.com>
	<45B94007.60609@bu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HAUYI-0000SI-MA
	for nfs@lists.sourceforge.net; Fri, 26 Jan 2007 09:07:51 -0800
Received: from an-out-0708.google.com ([209.85.132.243])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HAUYK-0008Ui-24
	for nfs@lists.sourceforge.net; Fri, 26 Jan 2007 09:07:52 -0800
Received: by an-out-0708.google.com with SMTP id d40so858142and
	for <nfs@lists.sourceforge.net>; Fri, 26 Jan 2007 09:07:47 -0800 (PST)
In-Reply-To: <45B94007.60609@bu.edu>
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

>
>> On 1/25/07, James Bardin <jbardin@bu.edu> wrote:
>>>
>>> > I'm almost there!
>>> > Between the nfs-utils patch, and the noacl option, I have my 32bit
>>> > systems working. (thanks Steve)
>>> >
>>> > On x86_64, I'm having kerberos problems (exact same config):
>>> >
>>> > rpc.gssd[4871]: handling krb5 upcall
>>> > rpc.gssd[4871]: getting credentials for client with uid xxxx for
>>> > server yyyy.bu.edu
>>> > rpc.gssd[4871]: CC file 'krb5cc_xxxx_bSULEy' being considered
>>> > rpc.gssd[4871]: CC file 'krb5cc_xxxx_bSULEy' matches name check and
>>> > has mtime of 1169750861
>>> > rpc.gssd[4871]: using FILE:/tmp/krb5cc_xxxx_bSULEy as credentials
>>> > cache for client with uid xxxx for server yyyy.bu.edu
>>> > rpc.gssd[4871]: creating context using euid xxxx (save_uid 0)
>>> > rpc.gssd[4871]: creating tcp client for server yyyy.bu.edu
>>> > rpc.gssd[4871]: WARNING: can't create rpc_clnt for server
>>> > engna1.bu.edu for user with uid xxxx: RPC: Success rpc.gssd[4871]:
>>> > WARNING: Failed to create krb5 context for user with uid xxxx for
>>> > server yyyy.bu.edu
>>> > rpc.gssd[4871]: doing error downcall
>>> >
>>> >
>>> x86_64 is working on an older version, I read the errata, and it
>>> shouldn't effect us, but something is wrong in the new ones. This is
>>> with sec=krb5.
>>> nfs-utils-1.0.6-77 causes the above problems
>>> nfs-utils-1.0.6-70 will hang on rpc.gssd
>>> nfs-utils-1.0.6-65 is working.
>>>
>>
> I don't know if it's related, but sometimes when I build an nfs-utils 
> src.rpm, it dumps out saying the GSS with KRB5 support not found. If I 
> try to build again, it works???
>


I've been testing on CentOS so far with the above results. 
Unfortunately, the RHEL4 system for which  I was testing, doesn't like 
nfs-utils-1.0.6-65.
With nfs-utils-1.0.6-65, rpcgssd dies at
rpc.gssd[5626]: rpcsec_gss: in authgss_create_default()
RPC: AUTH_GSS upcall timed out.
Please check user daemon is running!

The 70 77 patchlevels both give permission denied, and the above rpcgssd 
messages.
With the newest patch, I had to symlink lib/libgssapi_krb5.so -> 
lib64/libgssapi_krb5.so

This a new, up2date RHEL4, all rpm versions seem to match that of the 
CentOS I tested.


-jim


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
