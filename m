From: "Kevin Coffman" <kwc@umich.edu>
Subject: Re: nfs and kerberos authentification problem.
Date: Thu, 4 Sep 2008 15:31:05 -0400
Message-ID: <4d569c330809041231wcbddde8w419968280de9e39a@mail.gmail.com>
References: <4d569c330809031312p3515f4d8id9cbec94d871e058@mail.gmail.com>
	 <20080904165645.GG4536@fieldses.org> <48C01B5F.3060808@skynet.be>
	 <20080904173346.GJ4536@fieldses.org> <48C01DBD.7000309@skynet.be>
	 <20080904174928.GM4536@fieldses.org> <48C021E0.9000901@skynet.be>
	 <20080904183934.GO4536@fieldses.org> <48C02E95.1000406@skynet.be>
	 <20080904185954.GR4536@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: "=?ISO-8859-1?Q?Fran=E7ois_Valenduc?=" <francois.valenduc@skynet.be>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:42420 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752910AbYIDTbI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2008 15:31:08 -0400
Received: by wf-out-1314.google.com with SMTP id 27so85966wfd.4
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2008 12:31:06 -0700 (PDT)
In-Reply-To: <20080904185954.GR4536@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 4, 2008 at 2:59 PM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
> On Thu, Sep 04, 2008 at 08:53:09PM +0200, Fran=E7ois Valenduc wrote:
>> It's my home directory, so it has normal permission for such a direc=
tory:
>> drwxrwsr-x 77 francois francois 4,0K sep  4 20:43 francois/
>
> So everybody has permission to read that directory--OK, that shouldn'=
t
> be a problem.
>
>> I don't think there is someting strange with this. I start running o=
ut
>> of ideas to get it working. I have reenabled nfs4 (which I also trie=
d)
>> and it give the same problem. In order to do that, I off course chan=
ged
>> the exports file like this;
>
>> /export/francois
>> ordi-francois(nohide,rw,root_squash,no_subtree_check,sec=3Dsys:krb5)
>
> Let's just pick nfsv3 and stick with it; both nfsv3 and nfsv4 should
> work, and switching between the two just complicates the debugging.
>
> What does your mount commandline look like?
>
> Could you get a network trace?  Just start
>
>        tcpdump -s0 -wtmp.pcap
>
> then attempt the mount, then after it fails kill tcpdump and send me
> tmp.pcap.
>
> --b.

This may be a stupid question, but can you access the mount using
auth_sys?  As I think I said before, it looks like the Kerberos part
is working.  (Unless there are errors on the client side from
rpc.gssd.)
