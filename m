Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:44976 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751874AbaGHBdY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jul 2014 21:33:24 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1X4KHb-0001SP-6a
	for linux-nfs@vger.kernel.org; Tue, 08 Jul 2014 03:33:23 +0200
Received: from bitis.umrk.nl ([82.95.126.201])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 03:33:23 +0200
Received: from jwinius by bitis.umrk.nl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 03:33:23 +0200
To: linux-nfs@vger.kernel.org
From: Jaap Winius <jwinius@umrk.nl>
Subject: Re: NFSv4 cross-realm support
Date: Tue, 8 Jul 2014 01:33:10 +0000 (UTC)
Message-ID: <lpfhom$qku$1@ger.gmane.org>
References: <lp1gar$eb6$1@ger.gmane.org>
	<CAHVgHyVjoVb--cfbaopoUYA4vbDCjufJVng6OM2e82q0yEMthA@mail.gmail.com>
	<lpehhl$o74$1@ger.gmane.org>
	<CAHVgHyWU9B+VE=_qTEG2TVOyMHijzVTA0a2rVb_7hrjsKf7Jfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 07 Jul 2014 17:24:52 -0400, Andy Adamson wrote:

> I have never used the olcAuthzRegexp. Is this used to map potentially
> multiple principal@REALM names to the same UID name/number?

Correct. AFAIK MIT Kerberos doesn't issue tickets containing additional 
authorization data, so my site stores it in an OpenLDAP DIT. Moreover, 
when OpenLDAP is used as a backend for MIT Kerberos, it does a much 
better job at database synchronization than kprop. olcAuthzRegexp is a 
regular expression that maps GSSAPI-format user names to LDAP names. For 
example:

  olcAuthzRegexp: uid=([^,]+),cn=example.com,cn=gssapi,cn=auth
    uid=$1,ou=people,dc=example,dc=com

This works great for same-realm authentication, mapping bob@EXAMPLE.COM 
to the corresponding LDAP entry in ou=people where his account metadata 
is stored, containing UID, GID, shell and home directory information.

See http://www.rjsystems.nl/en/2100-d6-kerberos-openldap-provider.php for 
a more complete explanation.

For a cross-realm situation, that regex can be modified to map accounts 
from another trusted realm to an account with the same name in the local 
realm. However, in a bit of a twist, a foreign account, bob@EXAMPLE.NET, 
will start out with a slightly different GSSAPI format:

  uid=bob@example.net,cn=example.com,cn=gssapi,cn=auth

The aforementioned olcAuthzRegexp maps it to:

  uid=bob@example.net,ou=people,dc=example,dc=com

As a result, Bob's LDAP entry is not found, even though he is allowed to 
browse the local DIT (that just works). So, to make sure it works for 
users in the foreign realm, like Bob, who also happen to have a matching 
account in the local realm, I modified the regex to look like this:

  uid=([^,@]+)(@example.net)*,cn=example.com,cn=gssapi,cn=auth

That's one problem solved. Now what I need is for NFS to play nice. IMO, 
rpc.svcgssd should simply ask the local KDC if the foreign realm is to be 
trusted. Apparently, that's the way OpenLDAP, SSH and Dovecot IMAP do it, 
but that's not happening at the moment. So is this a bug, or what?

