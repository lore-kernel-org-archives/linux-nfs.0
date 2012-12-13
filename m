Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48350 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752800Ab2LMK3s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Dec 2012 05:29:48 -0500
Message-ID: <50C9AE0E.9070404@suse.com>
Date: Thu, 13 Dec 2012 15:59:34 +0530
From: Suresh Jayaraman <sjayaraman@suse.com>
MIME-Version: 1.0
To: bfields@fieldses.org, steved@redhat.com,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: idmapd doesn't map if the name (user or group) contains UTF8 characters
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

While investigating a bug report from our customer where NFSv4 name to
id mapping fails on the NFSv4 client (and maps to 'nobody') if a user or
group name contains non-ASCII characters (in this case it was Umlaut
characters) figured out we limit the characters to ASCII.

We seem to do this intentionally in utils/idmapd/idmapd.c: imconv()

...
        case IDMAP_CONV_NAMETOID:
                if (validateascii(im->im_name, sizeof(im->im_name)) == -1) {
                        im->im_status |= IDMAP_STATUS_INVALIDMSG;
                        return;
                }
...

with the validateacsii() function. I'm not sure why we had to limit the
characters in the NFSv4 domain name to ASCII only. If I have to guess:

   - perhaps it is risky because the shell might expand some characters?
   - Non-ASCII characters might have trouble between sharing systems
     that may use different encodings
   - to remain consistent with the tools like `groupadd' which considers
     a name with these characters as Invalid names (not sure why
     `groupadd' does so)


However, there seems to be a valid use case for allowing such
characters. For e.g. If Active Directory or LDAP is being used for
authentication, both of them seem to allow Umlaut characters. When used
together with such directory services, idmapd would end up mapping those
users or groups to 'nobody'.

So my questions are:

1) What is the reason behind not allowing non-ASCII characters?
2) Is the limitation historical and is not relevant now? In such case
   can we remove this check?
3) Would it make sense to allow atleast some UTF-8 characters that may
   be non-risky?

Thanks

-- 
Suresh Jayaraman
