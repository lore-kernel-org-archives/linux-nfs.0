From: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Fri, 23 Jan 2009 22:54:09 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0901232252510.25716@fbirervta.pbzchgretzou.qr>
References: <1232223441.3966.22.camel@localhost.localdomain>  <1232228261.27094.0.camel@macbook.infradead.org>  <20090117221932.GA4956@uranus.ravnborg.org>  <49725B1E.604@kernel.org>  <1232498319.3123.34.camel@localhost.localdomain>
 <1232726359.3504.18.camel@localhost.localdomain> <1232726658.3504.22.camel@localhost.localdomain> <alpine.LSU.2.00.0901231710350.15413@fbirervta.pbzchgretzou.qr> <497A3793.5090502@zytor.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jaswinder Singh Rajput <jaswinder@kernel.org>,
	"H. Peter Anvin" <hpa@kernel.org>, Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>,
	David Woodhouse <dwmw2@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>,
	urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org,
	linux-media@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, bfields@fieldses.org, neilb@suse.de,
	linux-nfs@vger.kernel.org, linux-raid@vger.kernel.org,
	dbrownell@users.sourceforge.net, netdev@vger.kernel.org,
	greg@kroah.com, linux-usb@vger.kernel.org,
	linux-mtd@lists.infradead.org, tiwai@suse.de,
	mchehab@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-usb-owner@vger.kernel.org>
In-Reply-To: <497A3793.5090502@zytor.com>
Sender: linux-usb-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Friday 2009-01-23 22:33, H. Peter Anvin wrote:
>>
>> I had an objection as previously stated -- namely that
>> <stdint.h> should be included to remain friendly to C++0x
>> programs which should use <cstdint> instead. Forcing
>> stdint.h is therefore not nice.
>
> FWIW, it's kind of pointless in that case; <cstdint> exports it into the std::
> namespace rather than the root namespace, so using stdint types still don't
> work.

Hm, maybe g++ defaults to std? Because this works without me using
"using std;"

#include <cstdint>
int main(void)
{
	uint32_t x;
}
